extends Node2D

@onready var nav_region: NavigationRegion2D = $NavigationRegion2D # Ajuste o nome se necessário

func _ready() -> void:
	# Quando o andar carregar com as pedras geradas, nós recarregamos a malha
	nav_region.bake_navigation_polygon()
