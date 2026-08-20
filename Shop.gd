extends Interactable
class_name Shop

@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var shop_ui: Panel = $CanvasLayer/ShopUI

func _ready() -> void:
	super._ready()

func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	shop_ui.open()
	
	# Faz o player parar de interagir
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		p.change_state(p.State.IDLE)
		p.interact_target = null
