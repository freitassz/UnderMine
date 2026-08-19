extends Node2D

@export var current_floor_data: MineFloorData 
var current_floor_index: int = 1

@export var ground_layer: TileMapLayer
@export var ore_layer: TileMapLayer

var stairs_scene = preload("res://Stairs.tscn")

func _ready() -> void:
	# Puxa os dados que o Portal enviou pelo Autoload
	if Global.floor_data_to_load != null:
		current_floor_data = Global.floor_data_to_load
		
	# Lê do Global se estivermos descendo andares na mesma sessão
	if "current_floor_index" in Global:
		current_floor_index = Global.current_floor_index
	else:
		Global.current_floor_index = 1
		
	# Depois de pegar a data correta, gera o mapa
	carregar_andar()

func carregar_andar() -> void:
	if current_floor_data == null:
		print("Erro: current_floor_data não foi colocado no Inspector do MineManager!")
		return
		
	if ground_layer == null or ore_layer == null:
		print("Erro: Faltam as referências dos TileMapLayers no MineManager!")
		return
		
	print("Gerando minérios para o andar: ", current_floor_data.floor_name, " (Nível ", current_floor_index, "/", current_floor_data.total_floors, ")")
	
	# Gera a mina
	ore_layer.generate_floor(current_floor_data, ground_layer)
	
	# NOVO: Força o chão a ler nossa lista inicial e aplicar os buracos
	ground_layer.notify_runtime_tile_data_update()
	
	_spawn_stairs()

func _spawn_stairs() -> void:
	var available_cells = ground_layer.get_used_cells()
	if available_cells.is_empty(): return
	
	# Pega todos os tiles que a ore_layer NÃO usou
	var free_cells = []
	for cell in available_cells:
		if not cell in ore_layer.active_ore_cells:
			free_cells.append(cell)
			
	# Se não tiver célula livre, rouba uma do chão normal
	var spawn_cell
	if free_cells.size() > 0:
		spawn_cell = free_cells.pick_random()
	else:
		spawn_cell = available_cells.pick_random()
		
	var stairs = stairs_scene.instantiate()
	add_child(stairs)
	stairs.global_position = ground_layer.map_to_local(spawn_cell)
	stairs.setup(self)

func descend_floor() -> void:
	if current_floor_index < current_floor_data.total_floors:
		Global.current_floor_index += 1
		get_tree().reload_current_scene()
	else:
		# Chegou no último andar! Retorna pra cidade
		Global.current_floor_index = 1
		get_tree().change_scene_to_file("res://main_scene.tscn")
