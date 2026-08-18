extends Panel

@onready var power_lbl = $VBoxContainer/Power/Label
@onready var power_btn = $VBoxContainer/Power/Button

@onready var speed_lbl = $VBoxContainer/Speed/Label
@onready var speed_btn = $VBoxContainer/Speed/Button

@onready var mult_lbl = $VBoxContainer/Multiplier/Label
@onready var mult_btn = $VBoxContainer/Multiplier/Button

var power_cost: int = 10
var speed_cost: int = 20
var mult_cost: int = 50

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
	if not player: return
	
	power_lbl.text = "Força de Mineração (Lvl " + str(player.mining_power) + ")"
	power_btn.text = "Comprar: " + str(power_cost)
	power_btn.disabled = Global.money < power_cost
	
	speed_lbl.text = "Velocidade de Mineração (Lvl " + str(player.mining_speed_level) + ")"
	speed_btn.text = "Comprar: " + str(speed_cost)
	speed_btn.disabled = Global.money < speed_cost
	
	mult_lbl.text = "Multiplicador de Dinheiro (x" + str(player.ore_multiplier) + ")"
	mult_btn.text = "Comprar: " + str(mult_cost)
	mult_btn.disabled = Global.money < mult_cost

func _on_power_pressed() -> void:
	if Global.money >= power_cost and player:
		Global.add_money(-power_cost)
		player.mining_power += 1
		power_cost = int(power_cost * 1.5)
		update_ui()

func _on_speed_pressed() -> void:
	if Global.money >= speed_cost and player:
		Global.add_money(-speed_cost)
		player.mining_speed_level += 1.0
		player.update_stats()
		speed_cost = int(speed_cost * 1.5)
		update_ui()

func _on_mult_pressed() -> void:
	if Global.money >= mult_cost and player:
		Global.add_money(-mult_cost)
		player.ore_multiplier += 0.5
		mult_cost = int(mult_cost * 2.0)
		update_ui()

func open() -> void:
	update_ui()
	show()
