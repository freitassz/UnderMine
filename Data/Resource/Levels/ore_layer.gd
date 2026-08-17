extends TileMapLayer

@export var base_ore_scene: PackedScene # Arraste a cena do seu Minério (Interactable) aqui no Inspector
@export_range(0.0, 1.0) var spawn_density: float = 0.4 # 40% de chance de nascer minério em um tile de chão

@export var max_ores: int = 500 # LIMITE DE SEGURANÇA: Nunca vai gerar mais que 50 minérios!

func generate_floor(floor_data: MineFloorData, ground_layer: TileMapLayer) -> void:
	# 1. Trava inicial de dados
	if floor_data == null or floor_data.ore_set == null:
		return
	
	# Limpa qualquer minério existente antes de gerar novos
	for child in get_children():
		child.queue_free()
		
	var available_cells = ground_layer.get_used_cells()
	var minérios_gerados = 0 # Contador de segurança
	
	for cell_pos in available_cells:
		# TRAVA DE EMERGÊNCIA: Se atingiu o limite, interrompe o loop imediatamente!
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
	
	# map_to_local centraliza a cena exatamente no meio do tile
	new_ore.global_position = map_to_local(cell_pos)
	
	# Chama a sua função setup que criamos antes!
	new_ore.setup(ore_data)

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
