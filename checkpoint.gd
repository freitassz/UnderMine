extends Area2D

@onready var sprite = $Sprite2D
@onready var particles = $CPUParticles2D
@onready var sfx = $AudioStreamPlayer2D

var is_active_checkpoint = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Verifica se este checkpoint específico foi o último salvo
	if Global.has_village_spawn and is_equal_approx(Global.village_spawn_pos_x, global_position.x) and is_equal_approx(Global.village_spawn_pos_y, global_position.y):
		set_active(true)
	else:
		set_active(false)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_active_checkpoint:
		activate_checkpoint()

func activate_checkpoint() -> void:
	# Desativa todos os outros checkpoints que possam estar ativos visualmente
	var all_checkpoints = get_tree().get_nodes_in_group("checkpoints")
	for cp in all_checkpoints:
		if cp != self and cp.has_method("set_active"):
			cp.set_active(false)
			
	set_active(true)
	
	# Efeitos visuais e sonoros
	particles.emitting = true
	if sfx.stream:
		sfx.bus = "SFX"
		sfx.play()
		
	# Salva a posição
	Global.village_spawn_pos_x = global_position.x
	Global.village_spawn_pos_y = global_position.y
	Global.has_village_spawn = true
	SaveManager.save_game()

func set_active(active: bool) -> void:
	is_active_checkpoint = active
	if sprite:
		# Assumindo frame 0 = desligado, frame 1 = ligado
		sprite.frame = 1 if active else 0
