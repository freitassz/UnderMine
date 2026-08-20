extends Panel

@onready var close_btn = $VBoxContainer/TopBar/CloseBtn
@onready var compass_stair_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/ItemPlaceholder1"
@onready var compass_ore_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/ItemPlaceholder2"
@onready var normal_pickaxe_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/NormalPickaxeBtn"
@onready var shockwave_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/ShockwaveBtn"

var cost_stair: int = 500
var cost_ore: int = 1000
var cost_shockwave: int = 200

var player: Node = null

func _ready() -> void:
	hide()
	close_btn.pressed.connect(hide)
	Global.ore_deselected.connect(hide)
	
	compass_stair_btn.pressed.connect(_buy_stair_compass)
	compass_ore_btn.pressed.connect(_buy_ore_compass)
	normal_pickaxe_btn.pressed.connect(_on_normal_pickaxe_pressed)
	shockwave_btn.pressed.connect(_on_shockwave_pressed)
	
	call_deferred("setup")
	Global.money_changed.connect(func(_amt): update_ui())

func setup() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	update_ui()

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

	if not Global.has_shockwave:
		shockwave_btn.text = "Comprar Shockwave (" + str(cost_shockwave) + " moedas)"
		shockwave_btn.disabled = Global.money < cost_shockwave
	else:
		if Global.current_mining_mode == 1: # SHOCKWAVE = 1
			shockwave_btn.text = "Shockwave (Equipado)"
			shockwave_btn.disabled = true
		else:
			shockwave_btn.text = "Shockwave (Equipar)"
			shockwave_btn.disabled = false
			
	if Global.current_mining_mode == 0: # ORIGINAL = 0
		normal_pickaxe_btn.text = "Picareta Normal (Equipado)"
		normal_pickaxe_btn.disabled = true
	else:
		normal_pickaxe_btn.text = "Picareta Normal (Equipar)"
		normal_pickaxe_btn.disabled = false

func _buy_stair_compass() -> void:
	if Global.money >= cost_stair and not Global.has_stair_compass:
		Global.add_money(-cost_stair)
		Global.has_stair_compass = true
		SaveManager.save_game()
		update_ui()

func _buy_ore_compass() -> void:
	if Global.money >= cost_ore and not Global.has_ore_compass:
		Global.add_money(-cost_ore)
		Global.has_ore_compass = true
		SaveManager.save_game()
		update_ui()

func _on_normal_pickaxe_pressed() -> void:
	Global.current_mining_mode = 0
	SaveManager.save_game()
	update_ui()

func _on_shockwave_pressed() -> void:
	if not Global.has_shockwave:
		if Global.money >= cost_shockwave:
			Global.add_money(-cost_shockwave)
			Global.has_shockwave = true
			Global.current_mining_mode = 1
			SaveManager.save_game()
			update_ui()
	else:
		Global.current_mining_mode = 1
		SaveManager.save_game()
		update_ui()

