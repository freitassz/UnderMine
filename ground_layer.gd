extends TileMapLayer

# Arraste o nó OreLayer do seu painel de cenas para cá no Inspector
@export var ore_layer: TileMapLayer

# 1. Avisa QUAIS quadrados do chão precisam ser alterados
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	# Se existe um tile desenhado na camada de minérios exatamente nesta mesma coordenada...
	if ore_layer.get_cell_source_id(coords) != -1:
		return true # ...avisamos que o chão debaixo dele precisa ser modificado
	return false

# 2. Executa a alteração no quadrado de chão
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	# Desliga completamente a navegação deste quadrado específico
	tile_data.set_navigation_polygon(0, null)
