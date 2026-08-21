extends Node

# Sinal para avisar a tela/UI sempre que o dinheiro mudar
signal money_changed(new_amount: int)
signal ascension_coins_changed(new_amount: int)
signal ore_selected(ore_name: String, max_hp: int, current_hp: int, lives: int)
signal ore_damaged(current_hp: int, lives: int)
signal ore_deselected()

var money: int = 0
var visual_money: int = 0
var ascension_coins: int = 0
var floor_data_to_load: MineFloorData = null
var current_floor_index: int = 1

var has_stair_compass: bool = false
var has_ore_compass: bool = false
var has_mining_dash: bool = false
var has_midas_luck: bool = false
var has_shockwave: bool = false
var has_chain_reaction: bool = false
var has_automatic: bool = false
var has_alchemical: bool = false
var is_afk_active: bool = false
var is_auto_upgrade_active: bool = false

var village_spawn_pos_x: float = 0.0
var village_spawn_pos_y: float = 0.0
var has_village_spawn: bool = false

var music_volume: float = 0.5
var sfx_volume: float = 0.5

var unlocked_levels: Dictionary = {}

var bgm_player: AudioStreamPlayer

func _ready() -> void:
	if AudioServer.get_bus_count() == 1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(1, "Music")
		AudioServer.add_bus()
		AudioServer.set_bus_name(2, "SFX")
		
	bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = preload("res://jubs1MENU.wav")
	bgm_player.bus = "Music"
	bgm_player.volume_db = 0.0 # Volume normal
	add_child(bgm_player)
	bgm_player.play()
	bgm_player.finished.connect(bgm_player.play)
	
	# Aguarda 1 frame para o SaveManager carregar o volume e então aplica
	call_deferred("_apply_audio_volumes")

func _apply_audio_volumes() -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(2, linear_to_db(sfx_volume))

# --- PLAYER STATS (Moved to Global for persistence) ---
var mining_power: int = 1
var mining_speed_level: float = 1.0
var ore_multiplier: float = 1.0
var current_mining_mode: int = 0 # 0=ORIGINAL, 1=SHOCKWAVE, 2=CHAIN_REACTION, 3=AUTOMATIC, 4=ALCHEMICAL

var power_cost: int = 10
var speed_cost: int = 10
var mult_cost: int = 10

# Usar uma função ajuda a organizar e disparar o sinal automaticamente
func format_num(value: int) -> String:
	if value < 1000:
		return str(value)
		
	var suffixes = ["", "k", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]
	var index = 0
	var float_val = float(value)
	
	while float_val >= 1000.0 and index < suffixes.size() - 1:
		float_val /= 1000.0
		index += 1
		
	# Formata para ter no máximo 2 casas decimais, mas tira o .0 se for exato
	var text_val = str(snapped(float_val, 0.01))
	if text_val.ends_with(".0"):
		text_val = text_val.substr(0, text_val.length() - 2)
	return text_val + suffixes[index]

func add_money(amount: int) -> void:
	money += amount
	
	if amount <= 0:
		# Se gastou dinheiro, atualiza a HUD na hora
		visual_money += amount
		money_changed.emit(visual_money)
	else:
		# O dinheiro interno já subiu, mas a HUD só vai atualizar
		# quando o número voador chegar nela, chamando a função abaixo!
		pass

func apply_visual_money(amount: int) -> void:
	visual_money += amount
	if visual_money > money:
		visual_money = money
	money_changed.emit(visual_money)

func _process(_delta: float) -> void:
	if not is_auto_upgrade_active: return
	
	# Calcula os leveis reais baseados nas variáveis de status
	var p_lvl = mining_power
	var s_lvl = int(mining_speed_level)
	var m_lvl = int(round((ore_multiplier - 1.0) / 0.05)) + 1
	
	# Descobre qual é o menor level
	var min_lvl = min(p_lvl, min(s_lvl, m_lvl))
	
	var bought_something = false
	
	# Prioridade: 1. Power, 2. Speed, 3. Mult
	if p_lvl == min_lvl and money >= power_cost:
		add_money(-power_cost)
		mining_power += 1
		power_cost = int(power_cost * 1.5)
		bought_something = true
		_trigger_player_levelup()
	elif s_lvl == min_lvl and money >= speed_cost:
		add_money(-speed_cost)
		mining_speed_level += 1.0
		speed_cost = int(speed_cost * 1.5)
		bought_something = true
		_trigger_player_levelup()
	elif m_lvl == min_lvl and money >= mult_cost:
		add_money(-mult_cost)
		ore_multiplier += 0.05
		mult_cost = int(mult_cost * 1.5)
		bought_something = true
		_trigger_player_levelup()

func _trigger_player_levelup() -> void:
	var tree = get_tree()
	if tree:
		var players = tree.get_nodes_in_group("player")
		if players.size() > 0:
			if players[0].has_method("update_stats"):
				players[0].update_stats()
			if players[0].has_method("play_level_up_effect"):
				players[0].play_level_up_effect()

func add_ascension_coins(amount: int) -> void:
	ascension_coins += amount
	ascension_coins_changed.emit(ascension_coins)
