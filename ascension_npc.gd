extends Interactable

@export var cost: int = 50000

@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var cost_label: Label = $CanvasLayer/Panel/VBoxContainer/CostLabel
@onready var yes_btn: Button = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/YesBtn
@onready var no_btn: Button = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/NoBtn

var is_ui_open: bool = false

func _ready() -> void:
	super._ready()
	ui_layer.hide()
	yes_btn.pressed.connect(_on_yes_pressed)
	no_btn.pressed.connect(_on_no_pressed)
	cost_label.text = "Renacer por " + Global.format_num(cost) + " moedas?\nVocê receberá 1 Moeda de Ascensão\ne perderá seus status atuais."

func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		p.change_state(p.State.IDLE)
		p.interact_target = null
		
	if is_ui_open: return
	open_ui()

func open_ui() -> void:
	is_ui_open = true
	ui_layer.show()
	yes_btn.disabled = Global.money < cost

func _on_yes_pressed() -> void:
	if Global.money >= cost:
		Global.money = 0
		Global.visual_money = 0
		Global.money_changed.emit(0)
		
		Global.add_ascension_coins(1)
		Global.stat_total_ascensions += 1
		
		# GULA DO ABISMO (Mantém 10% da força)
		var power_to_keep = 1
		if Global.has_void_gluttony:
			power_to_keep = max(1, int(Global.mining_power * 0.1))
			
		# Resetando os upgrades da pessoa:
		Global.mining_power = power_to_keep
		Global.mining_speed_level = 1.0
		Global.ore_multiplier = 1.0
		Global.current_mining_mode = 0
		
		Global.power_cost = 10
		Global.speed_cost = 10
		Global.mult_cost = 10
		
		Global.has_stair_compass = false
		Global.has_ore_compass = false
		Global.has_mining_dash = false
		Global.has_midas_luck = false
		Global.has_extra_hit = false
		Global.has_floor_multiplier = false
		
		Global.has_boots_1 = false
		Global.is_boots_active = false
		Global.has_auto_momentum = false
		Global.has_explosive_impact = false
		Global.has_supreme_dash = false
		Global.has_juros_compostos = false
		
		# Bloquear as entradas de minas liberadas
		Global.unlocked_levels.clear()
		Global.apply_tickets()
		
		SaveManager.save_game()
		
		is_ui_open = false
		ui_layer.hide()
		
		# Teleporta de volta ou só atualiza a cena
		get_tree().change_scene_to_file("res://main_scene.tscn")

func _on_no_pressed() -> void:
	is_ui_open = false
	ui_layer.hide()
