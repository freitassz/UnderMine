extends Panel

@onready var close_btn = $VBoxContainer/TopBar/CloseBtn
@onready var compass_stair_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/ItemPlaceholder1"
@onready var compass_ore_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/ItemPlaceholder2"
@onready var dash_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/DashBtn"
@onready var midas_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/MidasBtn"

@onready var normal_pickaxe_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/NormalPickaxeBtn"
@onready var shockwave_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/ShockwaveBtn"
@onready var chain_reaction_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/ChainReactionBtn"
@onready var automatic_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/AutomaticBtn"
@onready var alchemical_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/AlchemicalBtn"

var cost_stair: int = 500
var cost_ore: int = 1000
var cost_dash: int = 600
var cost_midas: int = 1500
var cost_shockwave: int = 1
var cost_chain_reaction: int = 2
var cost_automatic: int = 3
var cost_alchemical: int = 4

var player: Node = null

func _ready() -> void:
	hide()
	close_btn.pressed.connect(hide)
	Global.ore_deselected.connect(hide)
	
	compass_stair_btn.pressed.connect(_buy_stair_compass)
	compass_ore_btn.pressed.connect(_buy_ore_compass)
	dash_btn.pressed.connect(_buy_mining_dash)
	midas_btn.pressed.connect(_buy_midas_luck)
	normal_pickaxe_btn.pressed.connect(_on_normal_pickaxe_pressed)
	shockwave_btn.pressed.connect(_on_shockwave_pressed)
	chain_reaction_btn.pressed.connect(_on_chain_reaction_pressed)
	automatic_btn.pressed.connect(_on_automatic_pressed)
	alchemical_btn.pressed.connect(_on_alchemical_pressed)
	
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

	if Global.has_mining_dash:
		dash_btn.text = "Dash de Mineração (Comprado)"
		dash_btn.disabled = true
	else:
		dash_btn.text = "Dash de Mineração (" + str(cost_dash) + " moedas)"
		dash_btn.disabled = Global.money < cost_dash

	if Global.has_midas_luck:
		midas_btn.text = "Sorte de Midas (Comprado)"
		midas_btn.disabled = true
	else:
		midas_btn.text = "Sorte de Midas 15% Crit (" + str(cost_midas) + " moedas)"
		midas_btn.disabled = Global.money < cost_midas

	if not Global.has_shockwave:
		shockwave_btn.text = "Comprar Shockwave (" + str(cost_shockwave) + " Ascensão)"
		shockwave_btn.disabled = Global.ascension_coins < cost_shockwave
	else:
		if Global.current_mining_mode == 1:
			shockwave_btn.text = "Shockwave (Equipado)"
			shockwave_btn.disabled = true
		else:
			shockwave_btn.text = "Shockwave (Equipar)"
			shockwave_btn.disabled = false
			
	if not Global.has_chain_reaction:
		chain_reaction_btn.text = "Comprar Chain Reaction (" + str(cost_chain_reaction) + " Ascensão)"
		chain_reaction_btn.disabled = Global.ascension_coins < cost_chain_reaction
	else:
		if Global.current_mining_mode == 2:
			chain_reaction_btn.text = "Chain Reaction (Equipado)"
			chain_reaction_btn.disabled = true
		else:
			chain_reaction_btn.text = "Chain Reaction (Equipar)"
			chain_reaction_btn.disabled = false

	if not Global.has_automatic:
		automatic_btn.text = "Comprar Modo Automático (" + str(cost_automatic) + " Ascensão)"
		automatic_btn.disabled = Global.ascension_coins < cost_automatic
	else:
		if Global.current_mining_mode == 3:
			automatic_btn.text = "Modo Automático (Equipado) [Lucro -50%]"
			automatic_btn.disabled = true
		else:
			automatic_btn.text = "Modo Automático (Equipar)"
			automatic_btn.disabled = false

	if not Global.has_alchemical:
		alchemical_btn.text = "Comprar Transmutação (" + str(cost_alchemical) + " Ascensão)"
		alchemical_btn.disabled = Global.ascension_coins < cost_alchemical
	else:
		if Global.current_mining_mode == 4:
			alchemical_btn.text = "Transmutação Alquímica (Equipado)"
			alchemical_btn.disabled = true
		else:
			alchemical_btn.text = "Transmutação Alquímica (Equipar)"
			alchemical_btn.disabled = false
			
	if Global.current_mining_mode == 0:
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

func _buy_mining_dash() -> void:
	if Global.money >= cost_dash and not Global.has_mining_dash:
		Global.add_money(-cost_dash)
		Global.has_mining_dash = true
		SaveManager.save_game()
		update_ui()

func _buy_midas_luck() -> void:
	if Global.money >= cost_midas and not Global.has_midas_luck:
		Global.add_money(-cost_midas)
		Global.has_midas_luck = true
		SaveManager.save_game()
		update_ui()

func _on_normal_pickaxe_pressed() -> void:
	Global.current_mining_mode = 0
	SaveManager.save_game()
	update_ui()

func _on_shockwave_pressed() -> void:
	if not Global.has_shockwave:
		if Global.ascension_coins >= cost_shockwave:
			Global.add_ascension_coins(-cost_shockwave)
			Global.has_shockwave = true
			Global.current_mining_mode = 1
			SaveManager.save_game()
			update_ui()
	else:
		Global.current_mining_mode = 1
		SaveManager.save_game()
		update_ui()

func _on_chain_reaction_pressed() -> void:
	if not Global.has_chain_reaction:
		if Global.ascension_coins >= cost_chain_reaction:
			Global.add_ascension_coins(-cost_chain_reaction)
			Global.has_chain_reaction = true
			Global.current_mining_mode = 2
			SaveManager.save_game()
			update_ui()
	else:
		Global.current_mining_mode = 2
		SaveManager.save_game()
		update_ui()

func _on_automatic_pressed() -> void:
	if not Global.has_automatic:
		if Global.ascension_coins >= cost_automatic:
			Global.add_ascension_coins(-cost_automatic)
			Global.has_automatic = true
			Global.current_mining_mode = 3
			SaveManager.save_game()
			update_ui()
	else:
		Global.current_mining_mode = 3
		SaveManager.save_game()
		update_ui()

func _on_alchemical_pressed() -> void:
	if not Global.has_alchemical:
		if Global.ascension_coins >= cost_alchemical:
			Global.add_ascension_coins(-cost_alchemical)
			Global.has_alchemical = true
			Global.current_mining_mode = 4
			SaveManager.save_game()
			update_ui()
	else:
		Global.current_mining_mode = 4
		SaveManager.save_game()
		update_ui()

