extends TileMapLayer

# Arraste o nó OreLayer do seu painel de cenas para cá no Inspector
@export var ore_layer: TileMapLayer

# 1. Avisa QUAIS quadrados do chão precisam ser alterados
# Substitua o _use_tile_data_runtime_update inteiro por este:
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	# Se a coordenada atual estiver na lista de minérios, precisa ser modificada!
	if coords in ore_layer.active_ore_cells:
		return true 
	return false

# Esta função continua igualzinha a sua:
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0, null)
