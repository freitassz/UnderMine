extends Node2D

# Arraste o seu Resource "Mina Inicial" (MineFloorData) aqui no Inspector
@export var current_floor_data: MineFloorData 

# Arraste os seus TileMapLayers da cena para cá
@export var ground_layer: TileMapLayer
@export var ore_layer: TileMapLayer

func _ready() -> void:
	# Quando a cena carrega, mandamos gerar o andar imediatamente
	carregar_andar()

func carregar_andar() -> void:
	if current_floor_data == null:
		print("Erro: current_floor_data não foi colocado no Inspector do MineManager!")
		return
		
	if ground_layer == null or ore_layer == null:
		print("Erro: Faltam as referências dos TileMapLayers no MineManager!")
		return
		
	print("Gerando minérios para o andar: ", current_floor_data.floor_name)
	
	# Chama a função que criamos na etapa anterior
	ore_layer.generate_floor(current_floor_data, ground_layer)
