extends Panel

@onready var close_btn = $VBoxContainer/TopBar/CloseBtn
@onready var compass_stair_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/ItemPlaceholder1"
@onready var compass_ore_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/ItemPlaceholder2"

var cost_stair: int = 500
var cost_ore: int = 1000

func _ready() -> void:
	hide()
	close_btn.pressed.connect(hide)
	Global.ore_deselected.connect(hide)
	
	compass_stair_btn.pressed.connect(_buy_stair_compass)
	compass_ore_btn.pressed.connect(_buy_ore_compass)
	update_ui()
	
	Global.money_changed.connect(func(_amt): update_ui())

func open() -> void:
	update_ui()
	show()

func update_ui() -> void:
	if Global.has_stair_compass:
		compass_stair_btn.text = "Bússola de Escada (Comprado)"
		compass_stair_btn.disabled = true
	else:
		compass_stair_btn.text = "Bússola de Escada (" + str(cost_stair) + " moedas)"
		compass_stair_btn.disabled = Global.money < cost_stair
		
	if Global.has_ore_compass:
		compass_ore_btn.text = "Bússola de Minério Raro (Comprado)"
		compass_ore_btn.disabled = true
	else:
		compass_ore_btn.text = "Bússola de Minério Raro (" + str(cost_ore) + " moedas)"
		compass_ore_btn.disabled = Global.money < cost_ore

func _buy_stair_compass() -> void:
	if Global.money >= cost_stair and not Global.has_stair_compass:
		Global.add_money(-cost_stair)
		Global.has_stair_compass = true
		update_ui()

func _buy_ore_compass() -> void:
	if Global.money >= cost_ore and not Global.has_ore_compass:
		Global.add_money(-cost_ore)
		Global.has_ore_compass = true
		update_ui()

