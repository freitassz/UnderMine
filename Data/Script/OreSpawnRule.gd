class_name OreSpawnRule extends Resource

@export var ore: OreData # O minério (ex: Ouro, Carvão)

@export_category("Regras de Spawn")
@export var is_exact_amount: bool = false 

@export var exact_amount: int = 1 # Só será usado se a caixa acima for ativada
@export_range(0.0, 100.0) var spawn_chance: float = 10.0 # Usado se a caixa estiver desativada
