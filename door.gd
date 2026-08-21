extends Interactable
 
@export var cost: int = 100
@export var is_level_door: bool = false
@export var level_name: String = "Mina Oculta"

@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var cost_label: Label = $CanvasLayer/Panel/VBoxContainer/CostLabel
@onready var yes_btn: Button = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/YesBtn
@onready var no_btn: Button = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/NoBtn
 
var is_ui_open: bool = false
 
func _ready() -> void:
	super._ready() # Chama o _ready de Interactable para conectar o clique
	
	if is_level_door and Global.unlocked_levels.has(name):
		queue_free()
		return
		
	ui_layer.hide()
	yes_btn.pressed.connect(_on_yes_pressed)
	no_btn.pressed.connect(_on_no_pressed)
	cost_label.text = "Abrir por " + str(cost) + " moedas?"
 
# Quando o player chega e dá o primeiro "hit", a gente abre a interface
func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	# Faz o player parar de bater na porta
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		p.change_state(p.State.IDLE)
		p.interact_target = null

	if is_level_door:
		# Portas de level só são abertas pelo LevelShop, então não faz nada ao bater nelas
		return
		
	if is_ui_open: return
	open_ui()
 
func open_ui() -> void:
	is_ui_open = true
	ui_layer.show()
	
	# Habilita ou desabilita o botão Yes baseado no dinheiro
	yes_btn.disabled = Global.money < cost
 
func _on_yes_pressed() -> void:
	if Global.money >= cost:
		Global.add_money(-cost)
		is_ui_open = false
		ui_layer.hide()
		# Toca a nova animação épica em vez de apagar direto
		play_unlock_animation()
 
func _on_no_pressed() -> void:
	is_ui_open = false
	ui_layer.hide()

var is_shaking: bool = false
var shake_intensity: float = 2.0
var original_sprite_pos: Vector2

func play_unlock_animation() -> void:
	# Desabilita a colisão pra não atrapalhar
	if has_node("StaticBody2D/CollisionShape2D"):
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
		
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		original_sprite_pos = sprite.position
		
	var camera = get_viewport().get_camera_2d()
	
	var tween = create_tween()
	if camera:
		camera.top_level = true
		tween.tween_property(camera, "global_position", global_position, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	tween.tween_callback(_start_shake_and_particles)
	tween.tween_interval(0.8)
	
	tween.tween_callback(func():
		is_shaking = false
		if sprite: sprite.position = original_sprite_pos
		
		# Som de voar/explodir quando sai do chão seguro
		var sfx2 = AudioStreamPlayer2D.new()
		sfx2.stream = preload("res://assets/explosion (1).wav")
		sfx2.global_position = global_position
		var root = get_tree().current_scene
		if not root: root = get_tree().root
		root.add_child(sfx2)
		sfx2.play()
		sfx2.finished.connect(sfx2.queue_free)
	)
	
	# Porta subindo e sumindo rapidamente
	tween.tween_property(self, "position", position - Vector2(0, 40), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.4)
	
	# Câmera volta
	if camera:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			tween.tween_property(camera, "global_position", players[0].global_position, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.tween_callback(func():
				camera.top_level = false
				camera.position = Vector2.ZERO
			)
			
	tween.tween_callback(queue_free)

func _start_shake_and_particles() -> void:
	is_shaking = true
	
	# Som de tremor (explosion) seguro para não ser cortado
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = preload("res://assets/explosion.wav")
	sfx.global_position = global_position
	var root = get_tree().current_scene
	if not root: root = get_tree().root
	root.add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)
	
	# Cria partículas placeholder de poeira/pedras
	var particles = CPUParticles2D.new()
	particles.amount = 20
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(8, 8)
	particles.direction = Vector2(0, -1)
	particles.spread = 45.0
	particles.gravity = Vector2(0, 90)
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 50.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 3.0
	particles.color = Color(0.6, 0.5, 0.4) # Cor de poeira/terra
	add_child(particles)

func _process(delta: float) -> void:
	if is_shaking:
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			sprite.position = original_sprite_pos + Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
