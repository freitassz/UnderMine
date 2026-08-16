extends Interactable # Herda a lógica de clique que criamos antes!

@export var max_hp: int = 3
@export var money_value: int = 10

var current_hp: int

func _ready() -> void:
	# Garante que a base do Interactable também rode o _ready dela
	super._ready() 
	current_hp = max_hp

# Esta é a função que o Player vai chamar quando chegar perto e começar a bater
func interact() -> void:
	current_hp -= 1
	
	# ADICIONE ESTE PRINT PARA TESTE:
	print("O player bateu! HP atual da pedra: ", current_hp)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	if current_hp <= 0:
		_quebrar()

func _quebrar() -> void:
	# 1. Economia Direta: O minério destruído chama a função de dinheiro[cite: 1]
	Global.add_money(money_value)
	
	# Busca as camadas do mapa através dos grupos que criamos
	var ground_layer = get_tree().get_first_node_in_group("ground_layer")
	var ore_layer = get_tree().get_first_node_in_group("ore_layer")
	
	if ground_layer and ore_layer:
		# Converte a posição global da pedra para descobrir qual quadrado do Grid ela está ocupando
		var tile_coords = ground_layer.local_to_map(global_position)
		
		# Apaga o tile da pedra na camada visual de minérios (Substitui por vazio: -1)
		ore_layer.set_cell(tile_coords, -1)
		
		# Avisa o chão para recalcular a navegação agora que a pedra não está mais lá
		ground_layer.notify_runtime_tile_data_update()
		
	# 3. O minério deve ser destruído da memória (sem código de respawn)[cite: 1]
	queue_free()
