extends TileMapLayer

@export var base_ore_scene: PackedScene # Arraste a cena do seu Minério (Interactable) aqui no Inspector
@export_range(0.0, 1.0) var spawn_density: float = 0.4 # 40% de chance de nascer minério em um tile de chão

@export var max_ores: int = 500 # LIMITE DE SEGURANÇA: Nunca vai gerar mais que 50 minérios!
var active_ore_cells: Array[Vector2i] = [] # Nova variável!

func generate_floor(floor_data: MineFloorData, ground_layer: TileMapLayer) -> void:
	if floor_data == null or floor_data.ore_set == null:
		return
	
	active_ore_cells.clear() # Limpa as posições antigas
	
	for child in get_children():
		child.queue_free()
		
	var available_cells = ground_layer.get_used_cells()
	available_cells.shuffle() # Embaralha as células para os spawns exatos serem aleatórios
	var minérios_gerados = 0 # Contador de segurança
	
	# 1. Spawna primeiro os minérios de Quantidade Exata (Chefões/Únicos)
	for rule in floor_data.ore_set.spawn_rules:
		if rule.is_exact_amount:
			for i in range(rule.exact_amount):
				if available_cells.size() > 0 and minérios_gerados < max_ores:
					var cell_pos = available_cells.pop_back()
					if rule.ore != null:
						_spawn_ore_at(cell_pos, rule.ore)
						minérios_gerados += 1
	
	# 2. Continua com o Spawn Aleatório nas células que sobraram
	for cell_pos in available_cells:
		if minérios_gerados >= max_ores:
			print("Limite máximo de minérios atingido! Parando geração para evitar lag.")
			break 
			
		if randf() <= spawn_density:
			var chosen_ore_data = _pick_random_ore(floor_data.ore_set)
			
			if chosen_ore_data != null:
				_spawn_ore_at(cell_pos, chosen_ore_data)
				minérios_gerados += 1

# Instancia a cena, passa os dados e coloca na posição do Tile
func _spawn_ore_at(cell_pos: Vector2i, ore_data: OreData) -> void:
	var new_ore = base_ore_scene.instantiate()
	add_child(new_ore)
	
	new_ore.global_position = map_to_local(cell_pos)
	new_ore.setup(ore_data)
	
	# Salva a posição exata como "bloqueada" na nossa lista
	active_ore_cells.append(cell_pos)

# Sistema de "Roleta" para escolher o minério baseado nas chances (spawn_chance)
func _pick_random_ore(ore_set: OreSetData) -> OreData:
	if ore_set == null or ore_set.spawn_rules.is_empty():
		return null
		
	var total_weight: float = 0.0
	for rule in ore_set.spawn_rules:
		if not rule.is_exact_amount: # Vamos lidar com regras de quantidade exata depois, focando na chance agora
			total_weight += rule.spawn_chance
			
	var random_roll = randf_range(0.0, total_weight)
	var current_weight: float = 0.0
	
	for rule in ore_set.spawn_rules:
		if not rule.is_exact_amount:
			current_weight += rule.spawn_chance
			if random_roll <= current_weight:
				return rule.ore
				
	return null
