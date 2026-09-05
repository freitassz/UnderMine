extends Node2D

@onready var furniture_npc = get_node_or_null("FurnitureNPC")
var spawned_furnitures = {}

func _ready() -> void:
	if furniture_npc:
		for data in furniture_npc.furnitures_for_sale:
			if data and Global.unlocked_furnitures.has(data.furniture_name):
				spawn_furniture(data)

func spawn_furniture(data: FurnitureData) -> void:
	if spawned_furnitures.has(data.furniture_name): return
	
	if data.scene:
		var instance = data.scene.instantiate()
		instance.position = data.spawn_position
		add_child(instance)
		spawned_furnitures[data.furniture_name] = instance
