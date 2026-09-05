extends Interactable # Herda a lógica de clique que criamos antes!

# 1. Arraste um OreData (ex: Carvão) aqui no Inspector da cena para testar!
@export var test_data: OreData 

var my_data: OreData
var current_hp: int
var current_lives: int # Para a mecânica estilo Gold Mountain
var has_been_transmuted: bool = false

@onready var sprite: Sprite2D = $Sprite2D 

func _ready() -> void:
	super._ready() 
	add_to_group("ores") 
	
	# Se tiver um dado de teste no Inspector, ele se auto-configura para você testar
	if test_data != null:
		setup(test_data)

# Função chamada pelo Gerador (ou pelo _ready de teste acima)
func setup(data: OreData) -> void:
	my_data = data
	current_hp = my_data.max_hp
	current_lives = my_data.extra_lives
	
	if sprite and my_data.texture:
		sprite.texture = my_data.texture

# O Player chegou perto e começou a bater
# O Player chegou perto e começou a bater (Agora recebe os status do jogador!)
func take_damage(damage: int, multiplier: float, is_main_target: bool = true) -> void:
	if my_data == null: return 
	
	# SFX de batida (pitch aleatório para não ser repetitivo)
	var hit_sfx = AudioStreamPlayer2D.new()
	hit_sfx.stream = preload("res://stonehit.wav")
	if hit_sfx.stream:
		hit_sfx.bus = "SFX"
		hit_sfx.volume_db = -12.0 # Abaixa o volume
		hit_sfx.pitch_scale = randf_range(0.8, 1.2)
		hit_sfx.global_position = global_position
		var tree = get_tree()
		if tree:
			var root = tree.current_scene
			if not root: root = tree.root
			root.add_child(hit_sfx)
			hit_sfx.play()
			hit_sfx.finished.connect(hit_sfx.queue_free)
		
	# Calcula se o dano atravessa múltiplas vidas
	var total_hp_available = current_hp + (current_lives * my_data.max_hp)
	var damage_dealt = min(damage, total_hp_available)
	var lives_broken = 0
	
	current_hp -= damage_dealt
	
	while current_hp <= 0:
		lives_broken += 1
		if current_lives > 0:
			current_lives -= 1
			current_hp += my_data.max_hp
		else:
			break # Não tem mais vidas
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	if lives_broken > 0:
		_quebrar_multiplas_vidas(lives_broken, multiplier, is_main_target)
	else:
		# Se não quebrou nenhuma vida, só atualiza a barra da HUD
		if is_main_target:
			Global.ore_damaged.emit(current_hp, current_lives)

func insta_mine(multiplier: float) -> void:
	if my_data == null: return
	current_hp = 0
	_quebrar_multiplas_vidas(current_lives + 1, multiplier, true)

func _quebrar_multiplas_vidas(lives_broken: int, multiplier: float, is_main_target: bool) -> void:
	# Multiplica o dinheiro ganho pelo número de vidas estouradas de uma vez
	var total_money: int = int(my_data.money_drop * multiplier) * lives_broken
	
	var is_crit = false
	if Global.has_midas_luck and randf() <= 0.15:
		is_crit = true
		total_money *= 2
		
	Global.add_money(total_money)
	_spawn_floating_text(total_money, is_crit)
	
	if current_hp > 0:
		# A pedra sobreviveu (ainda tem vidas), só atualiza a HUD
		if is_main_target:
			Global.ore_damaged.emit(current_hp, current_lives)
	else:
		# A pedra foi totalmente aniquilada
		if is_main_target:
			Global.ore_deselected.emit()
			
		var ground_layer = get_tree().get_first_node_in_group("ground_layer")
		var ore_layer = get_tree().get_first_node_in_group("ore_layer")
		
		if ground_layer and ore_layer:
			var tile_coords = ground_layer.local_to_map(global_position)
			ore_layer.active_ore_cells.erase(tile_coords) 
			ground_layer.notify_runtime_tile_data_update()
			
		# Som de pedra totalmente minerada
		var mined_sfx = AudioStreamPlayer2D.new()
		mined_sfx.stream = preload("res://stonemined.wav")
		if mined_sfx.stream:
			mined_sfx.bus = "SFX"
			mined_sfx.volume_db = -10.0
			mined_sfx.global_position = global_position
			var tree = get_tree()
			if tree:
				var root = tree.current_scene
				if not root: root = tree.root
				root.add_child(mined_sfx)
				mined_sfx.play()
				mined_sfx.finished.connect(mined_sfx.queue_free)
			
		_create_shatter_effect()
		queue_free()

func _create_shatter_effect() -> void:
	if not sprite or not sprite.texture: return
	
	var tex = sprite.texture
	var w = tex.get_width() / 2.0
	var h = tex.get_height() / 2.0
	
	var tree = get_tree()
	if not tree: return
	var root = tree.current_scene
	if not root: root = tree.root
	
	for x in range(2):
		for y in range(2):
			var piece = Sprite2D.new()
			piece.texture = tex
			piece.region_enabled = true
			piece.region_rect = Rect2(x * w, y * h, w, h)
			
			var offset_pos = Vector2(x * w, y * h) - Vector2(w/2.0, h/2.0)
			piece.global_position = global_position + offset_pos
			
			# Copia o modulate caso a pedra original tenha cor aplicada via editor
			piece.modulate = sprite.modulate
			
			root.add_child(piece)
			
			var dir = offset_pos.normalized()
			if dir == Vector2.ZERO:
				dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
				
			var target_pos = piece.global_position + dir * randf_range(15.0, 30.0)
			var target_rot = randf_range(-PI, PI) * 2.0
			
			var tween = piece.create_tween()
			tween.tween_property(piece, "global_position", target_pos, 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(piece, "rotation", target_rot, 0.4)
			tween.parallel().tween_property(piece, "modulate:a", 0.0, 0.4)
			tween.tween_callback(piece.queue_free)

func _spawn_floating_text(amount: int, is_crit: bool) -> void:
	var tree = get_tree()
	if not tree: return
	
	var texts = tree.get_nodes_in_group("floating_texts")
	var my_text = null
	for t in texts:
		# Se a label pertencer a esta pedra e não tiver voado ainda
		if "ore_instance_id" in t and t.ore_instance_id == get_instance_id() and not t.flying:
			my_text = t
			break
			
	if my_text:
		my_text.add_amount(amount, is_crit)
	else:
		my_text = Label.new()
		my_text.set_script(preload("res://floating_money.gd"))
		my_text.add_to_group("floating_texts")
		
		var root = tree.current_scene
		if not root: root = tree.root
		root.add_child(my_text)
		
		my_text.setup(global_position, get_instance_id())
		my_text.add_amount(amount, is_crit)

# Adicione esta função no seu Ore.gd para avisar a UI que a pedra foi clicada
func select_ore() -> void:
	if my_data:
		Global.ore_selected.emit(my_data.name, my_data.max_hp, current_hp, current_lives)
	else:
		print("ERRO: my_data está vazio e não pode ser enviado para a HUD.")
