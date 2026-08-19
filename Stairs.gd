extends Interactable
class_name Stairs

var mine_scene: Node2D = null

func _ready() -> void:
	super._ready()
	add_to_group("stairs")

func setup(mine: Node2D) -> void:
	mine_scene = mine

func take_damage(_power: int, _mult: float) -> void:
	if mine_scene:
		mine_scene.descend_floor()
