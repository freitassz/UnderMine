extends Panel

@onready var close_btn = $VBoxContainer/TopBar/CloseBtn
@onready var compass_stair_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/ItemPlaceholder1"
@onready var compass_ore_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/ItemPlaceholder2"
@onready var dash_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/DashBtn"
@onready var midas_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/MidasBtn"
@onready var extra_hit_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/ExtraHitBtn"
@onready var floor_mult_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/FloorMultBtn"
@onready var boots1_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/Boots1Btn"
@onready var momentum_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/MomentumBtn"
@onready var explosive_impact_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/ExplosiveImpactBtn"
@onready var supreme_dash_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/SupremeDashBtn"
@onready var juros_compostos_btn = $"VBoxContainer/TabContainer/Itens 1/VBoxContainer/JurosCompostosBtn"

@onready var normal_pickaxe_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/NormalPickaxeBtn"
@onready var shockwave_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/ShockwaveBtn"
@onready var chain_reaction_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/ChainReactionBtn"
@onready var automatic_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/AutomaticBtn"
@onready var alchemical_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/AlchemicalBtn"
@onready var boomerang_btn = $"VBoxContainer/TabContainer/Itens 2/VBoxContainer/BoomerangBtn"

@onready var ticket1_btn = $"VBoxContainer/TabContainer/Ascensao/VBoxContainer/Ticket1Btn"
@onready var ticket2_btn = $"VBoxContainer/TabContainer/Ascensao/VBoxContainer/Ticket2Btn"
@onready var toque_magico_btn = $"VBoxContainer/TabContainer/Ascensao/VBoxContainer/ToqueMagicoBtn"
@onready var echo_strike_btn = $"VBoxContainer/TabContainer/Ascensao/VBoxContainer/EchoStrikeBtn"
@onready var void_gluttony_btn = $"VBoxContainer/TabContainer/Ascensao/VBoxContainer/VoidGluttonyBtn"
@onready var cosmic_synergy_btn = $"VBoxContainer/TabContainer/Ascensao/VBoxContainer/CosmicSynergyBtn"
@onready var time_warp_btn = $"VBoxContainer/TabContainer/Ascensao/VBoxContainer/TimeWarpBtn"

var cost_stair: int = 500
var cost_ore: int = 1000
var cost_dash: int = 600
var cost_midas: int = 1500
var cost_extra_hit: int = 3000
var cost_floor_mult: int = 5000

var cost_boots_1: int = 1500
var cost_momentum: int = 2500
var cost_explosive: int = 4000
var cost_supreme_dash: int = 20000
var cost_juros: int = 20000

var cost_shockwave: int = 1
var cost_chain_reaction: int = 2
var cost_automatic: int = 3
var cost_alchemical: int = 4
var cost_boomerang: int = 3

var cost_ticket1: int = 1
var cost_ticket2: int = 3
var cost_toque_magico: int = 5
var cost_echo: int = 3
var cost_void: int = 5
var cost_cosmic: int = 4
var cost_time_warp: int = 5

var player: Node = null

func _ready() -> void:
	hide()
	close_btn.pressed.connect(hide)
	Global.ore_deselected.connect(hide)
	
	compass_stair_btn.pressed.connect(_buy_stair_compass)
	compass_ore_btn.pressed.connect(_buy_ore_compass)
	dash_btn.pressed.connect(_buy_mining_dash)
	midas_btn.pressed.connect(_buy_midas_luck)
	extra_hit_btn.pressed.connect(_buy_extra_hit)
	floor_mult_btn.pressed.connect(_buy_floor_mult)
	
	boots1_btn.pressed.connect(_buy_boots1)
	momentum_btn.pressed.connect(_buy_momentum)
	explosive_impact_btn.pressed.connect(_buy_explosive)
	supreme_dash_btn.pressed.connect(_buy_supreme_dash)
	juros_compostos_btn.pressed.connect(_buy_juros)
	
	normal_pickaxe_btn.pressed.connect(_on_normal_pickaxe_pressed)
	shockwave_btn.pressed.connect(_on_shockwave_pressed)
	chain_reaction_btn.pressed.connect(_on_chain_reaction_pressed)
	automatic_btn.pressed.connect(_on_automatic_pressed)
	alchemical_btn.pressed.connect(_on_alchemical_pressed)
	boomerang_btn.pressed.connect(_on_boomerang_pressed)
	
	ticket1_btn.pressed.connect(_buy_ticket1)
	ticket2_btn.pressed.connect(_buy_ticket2)
	toque_magico_btn.pressed.connect(_buy_toque_magico)
	echo_strike_btn.pressed.connect(_buy_echo_strike)
	void_gluttony_btn.pressed.connect(_buy_void)
	cosmic_synergy_btn.pressed.connect(_buy_cosmic)
	time_warp_btn.pressed.connect(_buy_time_warp)
	
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
		compass_stair_btn.text = "Bússola de Escada (" + Global.format_num(cost_stair) + " moedas)"
		compass_stair_btn.disabled = Global.money < cost_stair
		
	if Global.has_ore_compass:
		compass_ore_btn.text = "Bússola de Minério Raro (Comprado)"
		compass_ore_btn.disabled = true
	else:
		compass_ore_btn.text = "Bússola de Minério Raro (" + Global.format_num(cost_ore) + " moedas)"
		compass_ore_btn.disabled = Global.money < cost_ore

	if Global.has_mining_dash:
		dash_btn.text = "Dash de Mineração (Comprado)"
		dash_btn.disabled = true
	else:
		dash_btn.text = "Dash de Mineração (" + Global.format_num(cost_dash) + " moedas)"
		dash_btn.disabled = Global.money < cost_dash

	if Global.has_midas_luck:
		midas_btn.text = "Sorte de Midas (Comprado)"
		midas_btn.disabled = true
	else:
		midas_btn.text = "Sorte de Midas 15% Crit (" + Global.format_num(cost_midas) + " moedas)"
		midas_btn.disabled = Global.money < cost_midas

	if Global.has_extra_hit:
		extra_hit_btn.text = "Hit Extra 10% (Comprado)"
		extra_hit_btn.disabled = true
	else:
		extra_hit_btn.text = "Hit Extra 10% Chance (" + Global.format_num(cost_extra_hit) + " moedas)"
		extra_hit_btn.disabled = Global.money < cost_extra_hit

	if Global.has_floor_multiplier:
		floor_mult_btn.text = "Multiplicador Subterrâneo (Comprado)"
		floor_mult_btn.disabled = true
	else:
		floor_mult_btn.text = "Multiplicador Subterrâneo +0.5x por Andar (" + Global.format_num(cost_floor_mult) + " moedas)"
		floor_mult_btn.disabled = Global.money < cost_floor_mult

	if not Global.has_boots_1:
		boots1_btn.text = "Botas Velozes (" + Global.format_num(cost_boots_1) + " moedas)"
		boots1_btn.disabled = Global.money < cost_boots_1
	else:
		if Global.is_boots_active:
			boots1_btn.text = "Botas Velozes (Ligado)"
		else:
			boots1_btn.text = "Botas Velozes (Desligado)"
		boots1_btn.disabled = false
		
	if Global.has_auto_momentum:
		momentum_btn.text = "Momentum Automático (Comprado)"
		momentum_btn.disabled = true
	else:
		momentum_btn.text = "Momentum Automático (" + Global.format_num(cost_momentum) + " moedas)"
		momentum_btn.disabled = Global.money < cost_momentum
		
	if Global.has_explosive_impact:
		explosive_impact_btn.text = "Impacto Explosivo 10x (Comprado)"
		explosive_impact_btn.disabled = true
	else:
		explosive_impact_btn.text = "Impacto Explosivo 10x no 1º Hit (" + Global.format_num(cost_explosive) + " moedas)"
		explosive_impact_btn.disabled = Global.money < cost_explosive
		
	if Global.has_supreme_dash:
		supreme_dash_btn.text = "Dash Supremo (Comprado)"
		supreme_dash_btn.disabled = true
	else:
		supreme_dash_btn.text = "Dash Supremo (" + Global.format_num(cost_supreme_dash) + " moedas)"
		supreme_dash_btn.disabled = Global.money < cost_supreme_dash or not Global.has_explosive_impact or not Global.has_mining_dash

	if Global.has_juros_compostos:
		juros_compostos_btn.text = "Cofre Rendeiro 1%/5s (Comprado)"
		juros_compostos_btn.disabled = true
	else:
		juros_compostos_btn.text = "Cofre Rendeiro 1%/5s (" + Global.format_num(cost_juros) + " moedas)"
		juros_compostos_btn.disabled = Global.money < cost_juros

	if not Global.has_shockwave:
		shockwave_btn.text = "Comprar Shockwave (" + Global.format_num(cost_shockwave) + " Ascensão)"
		shockwave_btn.disabled = Global.ascension_coins < cost_shockwave
	else:
		if Global.current_mining_mode == 1:
			shockwave_btn.text = "Shockwave (Equipado)"
			shockwave_btn.disabled = true
		else:
			shockwave_btn.text = "Shockwave (Equipar)"
			shockwave_btn.disabled = false
			
	if not Global.has_chain_reaction:
		chain_reaction_btn.text = "Comprar Chain Reaction (" + Global.format_num(cost_chain_reaction) + " Ascensão)"
		chain_reaction_btn.disabled = Global.ascension_coins < cost_chain_reaction
	else:
		if Global.current_mining_mode == 2:
			chain_reaction_btn.text = "Chain Reaction (Equipado)"
			chain_reaction_btn.disabled = true
		else:
			chain_reaction_btn.text = "Chain Reaction (Equipar)"
			chain_reaction_btn.disabled = false

	if not Global.has_automatic:
		automatic_btn.text = "Comprar Modo Automático (" + Global.format_num(cost_automatic) + " Ascensão)"
		automatic_btn.disabled = Global.ascension_coins < cost_automatic
	else:
		if Global.current_mining_mode == 3:
			automatic_btn.text = "Modo Automático (Equipado) [Lucro -50%]"
			automatic_btn.disabled = true
		else:
			automatic_btn.text = "Modo Automático (Equipar)"
			automatic_btn.disabled = false

	if not Global.has_alchemical:
		alchemical_btn.text = "Comprar Transmutação (" + Global.format_num(cost_alchemical) + " Ascensão)"
		alchemical_btn.disabled = Global.ascension_coins < cost_alchemical
	else:
		if Global.current_mining_mode == 4:
			alchemical_btn.text = "Transmutação Alquímica (Equipado)"
			alchemical_btn.disabled = true
		else:
			alchemical_btn.text = "Transmutação Alquímica (Equipar)"
			alchemical_btn.disabled = false
			
	if not Global.has_boomerang:
		boomerang_btn.text = "Comprar Bumerangue (" + Global.format_num(cost_boomerang) + " Ascensão)"
		boomerang_btn.disabled = Global.ascension_coins < cost_boomerang
	else:
		if Global.current_mining_mode == 5:
			boomerang_btn.text = "Picareta Bumerangue (Equipado)"
			boomerang_btn.disabled = true
		else:
			boomerang_btn.text = "Picareta Bumerangue (Equipar)"
			boomerang_btn.disabled = false
			
	if Global.current_mining_mode == 0:
		normal_pickaxe_btn.text = "Picareta Normal (Equipado)"
		normal_pickaxe_btn.disabled = true
	else:
		normal_pickaxe_btn.text = "Picareta Normal (Equipar)"
		normal_pickaxe_btn.disabled = false
		
	if Global.has_ticket_minas_lv1:
		ticket1_btn.text = "Ticket Minas Lv1 (Comprado)"
		ticket1_btn.disabled = true
	else:
		ticket1_btn.text = "Ticket Minas Lv1 (" + Global.format_num(cost_ticket1) + " Ascensão)"
		ticket1_btn.disabled = Global.ascension_coins < cost_ticket1
		
	if Global.has_ticket_minas_lv2:
		ticket2_btn.text = "Ticket Minas Lv2 (Comprado)"
		ticket2_btn.disabled = true
	else:
		ticket2_btn.text = "Ticket Minas Lv2 (" + Global.format_num(cost_ticket2) + " Ascensão)"
		ticket2_btn.disabled = Global.ascension_coins < cost_ticket2
		
	if Global.has_toque_magico:
		toque_magico_btn.text = "Toque Mágico (Comprado)"
		toque_magico_btn.disabled = true
	else:
		toque_magico_btn.text = "Toque Mágico 1% (" + Global.format_num(cost_toque_magico) + " Ascensão)"
		toque_magico_btn.disabled = Global.ascension_coins < cost_toque_magico
		
	if Global.has_echo_strike:
		echo_strike_btn.text = "Eco Strike (Comprado)"
		echo_strike_btn.disabled = true
	else:
		echo_strike_btn.text = "Eco Strike (" + Global.format_num(cost_echo) + " Ascensão)"
		echo_strike_btn.disabled = Global.ascension_coins < cost_echo

	if Global.has_void_gluttony:
		void_gluttony_btn.text = "Gula do Abismo (Comprado)"
		void_gluttony_btn.disabled = true
	else:
		void_gluttony_btn.text = "Gula do Abismo 10% Força Pós-Ascensão (" + Global.format_num(cost_void) + " Ascensão)"
		void_gluttony_btn.disabled = Global.ascension_coins < cost_void

	if Global.has_cosmic_synergy:
		cosmic_synergy_btn.text = "Sintonia Cósmica (Comprado)"
		cosmic_synergy_btn.disabled = true
	else:
		cosmic_synergy_btn.text = "Sintonia Cósmica (" + Global.format_num(cost_cosmic) + " Ascensão)"
		cosmic_synergy_btn.disabled = Global.ascension_coins < cost_cosmic

	if Global.has_time_warp:
		time_warp_btn.text = "Distorção Temporal (Comprado)"
		time_warp_btn.disabled = true
	else:
		time_warp_btn.text = "Distorção Temporal (" + Global.format_num(cost_time_warp) + " Ascensão)"
		time_warp_btn.disabled = Global.ascension_coins < cost_time_warp

func _buy_stair_compass() -> void:
	if Global.money >= cost_stair and not Global.has_stair_compass:
		Global.add_money(-cost_stair)
		Global.has_stair_compass = true
		SaveManager.save_game()
		update_ui()

func _buy_ticket1() -> void:
	if Global.ascension_coins >= cost_ticket1 and not Global.has_ticket_minas_lv1:
		Global.add_ascension_coins(-cost_ticket1)
		Global.has_ticket_minas_lv1 = true
		Global.apply_tickets()
		SaveManager.save_game()
		update_ui()

func _buy_ticket2() -> void:
	if Global.ascension_coins >= cost_ticket2 and not Global.has_ticket_minas_lv2:
		Global.add_ascension_coins(-cost_ticket2)
		Global.has_ticket_minas_lv2 = true
		Global.apply_tickets()
		SaveManager.save_game()
		update_ui()

func _buy_toque_magico() -> void:
	if Global.ascension_coins >= cost_toque_magico and not Global.has_toque_magico:
		Global.add_ascension_coins(-cost_toque_magico)
		Global.has_toque_magico = true
		SaveManager.save_game()
		update_ui()
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

func _buy_extra_hit() -> void:
	if Global.money >= cost_extra_hit and not Global.has_extra_hit:
		Global.add_money(-cost_extra_hit)
		Global.has_extra_hit = true
		SaveManager.save_game()
		update_ui()

func _buy_floor_mult() -> void:
	if Global.money >= cost_floor_mult and not Global.has_floor_multiplier:
		Global.add_money(-cost_floor_mult)
		Global.has_floor_multiplier = true
		SaveManager.save_game()
		update_ui()

func _buy_boots1() -> void:
	if not Global.has_boots_1:
		if Global.money >= cost_boots_1:
			Global.add_money(-cost_boots_1)
			Global.has_boots_1 = true
			Global.is_boots_active = true
			_update_player_speed()
			SaveManager.save_game()
			update_ui()
	else:
		Global.is_boots_active = not Global.is_boots_active
		_update_player_speed()
		SaveManager.save_game()
		update_ui()

func _buy_momentum() -> void:
	if Global.money >= cost_momentum and not Global.has_auto_momentum:
		Global.add_money(-cost_momentum)
		Global.has_auto_momentum = true
		SaveManager.save_game()
		update_ui()

func _buy_explosive() -> void:
	if Global.money >= cost_explosive and not Global.has_explosive_impact:
		Global.add_money(-cost_explosive)
		Global.has_explosive_impact = true
		SaveManager.save_game()
		update_ui()

func _buy_supreme_dash() -> void:
	if Global.money >= cost_supreme_dash and not Global.has_supreme_dash and Global.has_explosive_impact and Global.has_mining_dash:
		Global.add_money(-cost_supreme_dash)
		Global.has_supreme_dash = true
		SaveManager.save_game()
		update_ui()

func _buy_juros() -> void:
	if Global.money >= cost_juros and not Global.has_juros_compostos:
		Global.add_money(-cost_juros)
		Global.has_juros_compostos = true
		SaveManager.save_game()
		update_ui()

func _buy_echo_strike() -> void:
	if Global.ascension_coins >= cost_echo and not Global.has_echo_strike:
		Global.add_ascension_coins(-cost_echo)
		Global.has_echo_strike = true
		SaveManager.save_game()
		update_ui()

func _buy_void() -> void:
	if Global.ascension_coins >= cost_void and not Global.has_void_gluttony:
		Global.add_ascension_coins(-cost_void)
		Global.has_void_gluttony = true
		SaveManager.save_game()
		update_ui()

func _buy_cosmic() -> void:
	if Global.ascension_coins >= cost_cosmic and not Global.has_cosmic_synergy:
		Global.add_ascension_coins(-cost_cosmic)
		Global.has_cosmic_synergy = true
		SaveManager.save_game()
		update_ui()

func _buy_time_warp() -> void:
	if Global.ascension_coins >= cost_time_warp and not Global.has_time_warp:
		Global.add_ascension_coins(-cost_time_warp)
		Global.has_time_warp = true
		SaveManager.save_game()
		update_ui()

func _on_boomerang_pressed() -> void:
	if not Global.has_boomerang:
		if Global.ascension_coins >= cost_boomerang:
			Global.add_ascension_coins(-cost_boomerang)
			Global.has_boomerang = true
			Global.current_mining_mode = 5
			_unlock_and_equip_skin(4)
			SaveManager.save_game()
			update_ui()
	else:
		Global.current_mining_mode = 5
		_unlock_and_equip_skin(4)
		SaveManager.save_game()
		update_ui()

func _update_player_speed() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].apply_speed_upgrades()

func _on_normal_pickaxe_pressed() -> void:
	Global.current_mining_mode = 0
	_unlock_and_equip_skin(-1)
	SaveManager.save_game()
	update_ui()

func _on_shockwave_pressed() -> void:
	if not Global.has_shockwave:
		if Global.ascension_coins >= cost_shockwave:
			Global.add_ascension_coins(-cost_shockwave)
			Global.has_shockwave = true
			Global.current_mining_mode = 1
			_unlock_and_equip_skin(0)
			SaveManager.save_game()
			update_ui()
	else:
		Global.current_mining_mode = 1
		_unlock_and_equip_skin(0)
		SaveManager.save_game()
		update_ui()

func _on_chain_reaction_pressed() -> void:
	if not Global.has_chain_reaction:
		if Global.ascension_coins >= cost_chain_reaction:
			Global.add_ascension_coins(-cost_chain_reaction)
			Global.has_chain_reaction = true
			Global.current_mining_mode = 2
			_unlock_and_equip_skin(1)
			SaveManager.save_game()
			update_ui()
	else:
		Global.current_mining_mode = 2
		_unlock_and_equip_skin(1)
		SaveManager.save_game()
		update_ui()

func _on_automatic_pressed() -> void:
	if not Global.has_automatic:
		if Global.ascension_coins >= cost_automatic:
			Global.add_ascension_coins(-cost_automatic)
			Global.has_automatic = true
			Global.current_mining_mode = 3
			_unlock_and_equip_skin(2)
			SaveManager.save_game()
			update_ui()
	else:
		Global.current_mining_mode = 3
		_unlock_and_equip_skin(2)
		SaveManager.save_game()
		update_ui()

func _on_alchemical_pressed() -> void:
	if not Global.has_alchemical:
		if Global.ascension_coins >= cost_alchemical:
			Global.add_ascension_coins(-cost_alchemical)
			Global.has_alchemical = true
			Global.current_mining_mode = 4
			_unlock_and_equip_skin(3)
			SaveManager.save_game()
			update_ui()
	else:
		Global.current_mining_mode = 4
		_unlock_and_equip_skin(3)
		SaveManager.save_game()
		update_ui()

func _unlock_and_equip_skin(index: int) -> void:
	match index:
		0: Global.skin_1_unlocked = true
		1: Global.skin_2_unlocked = true
		2: Global.skin_3_unlocked = true
		3: Global.skin_4_unlocked = true
		4: Global.skin_5_unlocked = true
		
	Global.equipped_skin_index = index
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		if index == -1 or index >= p.skins.size():
			p.apply_skin(null)
		else:
			if p.skins[index]:
				p.apply_skin(p.skins[index])

