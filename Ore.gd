extends Interactable # Herda a lógica de clique que criamos antes!

# 1. Arraste um OreData (ex: Carvão) aqui no Inspector da cena para testar!
@export var test_data: OreData 

var my_data: OreData
var current_hp: int
var current_lives: int # Para a mecânica estilo Gold Mountain

@onready var sprite: Sprite2D = $Sprite2D 

func _ready() -> void:
	super._ready() 
	
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
func interact() -> void:
	# Proteção: se a pedra não tiver dados, ignora o clique
	if my_data == null: 
		print("Erro: Esta pedra não recebeu um OreData!")
		return 
		
	current_hp -= 1
	print("Bateu! HP: ", current_hp, " | Vidas restantes: ", current_lives)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	if current_hp <= 0:
		_quebrar()

func _quebrar() -> void:
	# Economia Direta: Dá o dinheiro instantaneamente ao quebrar uma vida[cite: 1]
	Global.add_money(my_data.money_drop)
	
	if current_lives > 0:
		# Mecânica Gold Mountain: Perde uma vida, reseta o HP e continua vivo
		current_lives -= 1
		current_hp = my_data.max_hp
		print("Minério quebrou, mas tem vidas extras! Vidas: ", current_lives)
	else:
		# Sem vidas extras, o minério é destruído permanentemente (sem respawn)[cite: 1]
		var ground_layer = get_tree().get_first_node_in_group("ground_layer")
		var ore_layer = get_tree().get_first_node_in_group("ore_layer")
		
		if ground_layer and ore_layer:
			var tile_coords = ground_layer.local_to_map(global_position)
			ore_layer.set_cell(tile_coords, -1)
			ground_layer.notify_runtime_tile_data_update()
			
		queue_free()
