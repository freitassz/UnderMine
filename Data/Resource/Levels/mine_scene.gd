extends Node2D

# Arraste o seu Resource "Mina Inicial" (MineFloorData) aqui no Inspector
@export var current_floor_data: MineFloorData 

# Arraste os seus TileMapLayers da cena para cá
@export var ground_layer: TileMapLayer
@export var ore_layer: TileMapLayer

func _ready() -> void:
	# Puxa os dados que o Portal enviou pelo Autoload
	if Global.floor_data_to_load != null:
		current_floor_data = Global.floor_data_to_load
		
	# Depois de pegar a data correta, gera o mapa
	carregar_andar()

func carregar_andar() -> void:
	if current_floor_data == null:
		print("Erro: current_floor_data não foi colocado no Inspector do MineManager!")
		return
		
	if ground_layer == null or ore_layer == null:
		print("Erro: Faltam as referências dos TileMapLayers no MineManager!")
		return
		
	print("Gerando minérios para o andar: ", current_floor_data.floor_name)
	
	# Gera a mina
	ore_layer.generate_floor(current_floor_data, ground_layer)
	
	# NOVO: Força o chão a ler nossa lista inicial e aplicar os buracos
	ground_layer.notify_runtime_tile_data_update()
