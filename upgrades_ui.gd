extends Panel

@onready var power_lbl = $VBoxContainer/Power/Label
@onready var power_btn = $VBoxContainer/Power/Button

@onready var speed_lbl = $VBoxContainer/Speed/Label
@onready var speed_btn = $VBoxContainer/Speed/Button

@onready var mult_lbl = $VBoxContainer/Multiplier/Label
@onready var mult_btn = $VBoxContainer/Multiplier/Button

var player: Node = null

func _ready() -> void:
	hide()
	# Wait for a frame to ensure player is ready
	call_deferred("setup")
	Global.money_changed.connect(_on_money_changed)
	
	$VBoxContainer/TopBar/CloseBtn.pressed.connect(hide)
	power_btn.pressed.connect(_on_power_pressed)
	speed_btn.pressed.connect(_on_speed_pressed)
	mult_btn.pressed.connect(_on_mult_pressed)

func setup() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	update_ui()

func _on_money_changed(_money: int) -> void:
	update_ui()

func update_ui() -> void:
	power_lbl.text = "Força de Mineração (Lvl " + str(Global.mining_power) + ")"
	power_btn.text = "Comprar: " + Global.format_num(Global.power_cost)
	power_btn.disabled = Global.money < Global.power_cost
	
	speed_lbl.text = "Velocidade de Mineração (Lvl " + str(Global.mining_speed_level) + ")"
	speed_btn.text = "Comprar: " + Global.format_num(Global.speed_cost)
	speed_btn.disabled = Global.money < Global.speed_cost
	
	mult_lbl.text = "Multiplicador de Dinheiro (x" + str(snapped(Global.ore_multiplier, 0.01)) + ")"
	mult_btn.text = "Comprar: " + Global.format_num(Global.mult_cost)
	mult_btn.disabled = Global.money < Global.mult_cost

func _on_power_pressed() -> void:
	if Global.money >= Global.power_cost:
		Global.add_money(-Global.power_cost)
		Global.mining_power += 1
		Global.power_cost = int(Global.power_cost * 1.5)
		SaveManager.save_game()
		Global._trigger_player_levelup()
		update_ui()

func _on_speed_pressed() -> void:
	if Global.money >= Global.speed_cost:
		Global.add_money(-Global.speed_cost)
		Global.mining_speed_level += 1.0
		Global.speed_cost = int(Global.speed_cost * 1.5)
		SaveManager.save_game()
		Global._trigger_player_levelup()
		update_ui()

func _on_mult_pressed() -> void:
	if Global.money >= Global.mult_cost:
		Global.add_money(-Global.mult_cost)
		Global.ore_multiplier += 0.05
		Global.mult_cost = int(Global.mult_cost * 1.5)
		SaveManager.save_game()
		Global._trigger_player_levelup()
		update_ui()

func open() -> void:
	update_ui()
	show()
