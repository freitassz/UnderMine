extends Interactable
class_name SlotMachineWorld

var ui_scene = preload("res://slot_machine_ui.tscn")
var ui_instance: CanvasLayer = null

func _ready() -> void:
	super._ready()
	
	ui_instance = ui_scene.instantiate()
	add_child(ui_instance)

func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	if ui_instance.has_method("open"):
		ui_instance.open()
		
	# Para o jogador
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		p.change_state(p.State.IDLE)
		p.interact_target = null
