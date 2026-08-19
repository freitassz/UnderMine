extends Interactable # Herda a lógica de clique que criamos antes!

# 1. Arraste um OreData (ex: Carvão) aqui no Inspector da cena para testar!
@export var test_data: OreData 

var my_data: OreData
var current_hp: int
var current_lives: int # Para a mecânica estilo Gold Mountain

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
func take_damage(damage: int, multiplier: float) -> void:
	if my_data == null: return 
		
	current_hp -= damage
	Global.ore_damaged.emit(current_hp, current_lives) # <-- NOVO: Atualiza a barra de vida
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	if current_hp <= 0:
		_quebrar(multiplier)

func _quebrar(multiplier: float) -> void:
	var total_money: int = int(my_data.money_drop * multiplier)
	Global.add_money(total_money)
	
	if current_lives > 0:
		current_lives -= 1
		current_hp = my_data.max_hp
		Global.ore_damaged.emit(current_hp, current_lives) # <-- NOVO: Atualiza barra após resetar HP
	else:
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

# Adicione esta função no seu Ore.gd para avisar a UI que a pedra foi clicada
func select_ore() -> void:
	if my_data:
		Global.ore_selected.emit(my_data.name, my_data.max_hp, current_hp, current_lives)
	else:
		print("ERRO: my_data está vazio e não pode ser enviado para a HUD.")
