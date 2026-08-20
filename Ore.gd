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
		
	current_hp -= damage
	if is_main_target:
		Global.ore_damaged.emit(current_hp, current_lives) # <-- Atualiza a barra de vida apenas do alvo principal
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	if current_hp <= 0:
		_quebrar(multiplier, is_main_target)

func _quebrar(multiplier: float, is_main_target: bool) -> void:
	var total_money: int = int(my_data.money_drop * multiplier)
	
	var is_crit = false
	if Global.has_midas_luck and randf() <= 0.15:
		is_crit = true
		total_money *= 2
		
	Global.add_money(total_money)
	_spawn_floating_text(total_money, is_crit)
	
	if current_lives > 0:
		current_lives -= 1
		current_hp = my_data.max_hp
		if is_main_target:
			Global.ore_damaged.emit(current_hp, current_lives) # <-- Atualiza barra apenas do principal
	else:
		if is_main_target:
			Global.ore_deselected.emit()
		var ground_layer = get_tree().get_first_node_in_group("ground_layer")
		var ore_layer = get_tree().get_first_node_in_group("ore_layer")
		
		if ground_layer and ore_layer:
			var tile_coords = ground_layer.local_to_map(global_position)
			
			# NOVO: Remove da lista de buracos bloqueados
			ore_layer.active_ore_cells.erase(tile_coords) 
			
			# Isso força o chão a recriar o polígono de navegação onde estava a pedra
			ground_layer.notify_runtime_tile_data_update()
			
		# Sem Respawn: O minério some da tela
		queue_free()

func _spawn_floating_text(amount: int, is_crit: bool) -> void:
	var label = Label.new()
	
	if is_crit:
		label.text = "CRIT! +" + str(amount)
		label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1)) # Dourado brilhante
		label.add_theme_font_size_override("font_size", 10)
	else:
		label.text = "+" + str(amount)
		label.add_theme_color_override("font_color", Color(1, 1, 0, 1)) # Amarelo normal
		label.add_theme_font_size_override("font_size", 8)
		
	# Adiciona contorno fino para visibilidade em 8-bit
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	
	# Precisamos adicionar a label no pai (ou root) porque este Ore vai ser deletado
	var tree = get_tree()
	if not tree: return
	
	var root = tree.current_scene
	if root == null: root = tree.root
	
	root.add_child(label)
	
	# Ajusta posição inicial (mais perto da pedra para estética 8-bit)
	label.global_position = global_position - Vector2(label.size.x / 2.0, 8)
	
	# Cria a animação vinculada à própria label (assim o tween não morre quando a pedra for apagada)
	var tween = label.create_tween()
	var target_pos = label.global_position - Vector2(0, 16) # Sobe 16 pixels (2 blocos)
	
	tween.tween_property(label, "global_position", target_pos, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_callback(label.queue_free)

# Adicione esta função no seu Ore.gd para avisar a UI que a pedra foi clicada
func select_ore() -> void:
	if my_data:
		Global.ore_selected.emit(my_data.name, my_data.max_hp, current_hp, current_lives)
	else:
		print("ERRO: my_data está vazio e não pode ser enviado para a HUD.")
