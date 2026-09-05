extends Node

const SAVE_PATH = "user://save_data.json"

func _ready() -> void:
	load_game()

func save_game() -> void:
	var save_data = {
		"money": Global.money,
		"ascension_coins": Global.ascension_coins,
		"has_stair_compass": Global.has_stair_compass,
		"has_ore_compass": Global.has_ore_compass,
		"has_mining_dash": Global.has_mining_dash,
		"has_midas_luck": Global.has_midas_luck,
		"has_extra_hit": Global.has_extra_hit,
		"has_floor_multiplier": Global.has_floor_multiplier,
		"has_shockwave": Global.has_shockwave,
		"has_chain_reaction": Global.has_chain_reaction,
		
		"has_boots_1": Global.has_boots_1,
		"is_boots_active": Global.is_boots_active,
		"has_auto_momentum": Global.has_auto_momentum,
		"has_explosive_impact": Global.has_explosive_impact,
		"has_supreme_dash": Global.has_supreme_dash,
		
		"has_automatic": Global.has_automatic,
		"has_alchemical": Global.has_alchemical,
		"has_ticket_minas_lv1": Global.has_ticket_minas_lv1,
		"has_ticket_minas_lv2": Global.has_ticket_minas_lv2,
		"has_toque_magico": Global.has_toque_magico,
		
		"has_juros_compostos": Global.has_juros_compostos,
		"has_echo_strike": Global.has_echo_strike,
		"has_void_gluttony": Global.has_void_gluttony,
		"has_cosmic_synergy": Global.has_cosmic_synergy,
		"has_boomerang": Global.has_boomerang,
		"has_time_warp": Global.has_time_warp,
		
		"is_auto_upgrade_active": Global.is_auto_upgrade_active,
		"unlocked_levels": Global.unlocked_levels,
		"unlocked_furnitures": Global.unlocked_furnitures,
		"equipped_skin_index": Global.equipped_skin_index,
		
		"skin_1_unlocked": Global.skin_1_unlocked,
		"skin_2_unlocked": Global.skin_2_unlocked,
		"skin_3_unlocked": Global.skin_3_unlocked,
		"skin_4_unlocked": Global.skin_4_unlocked,
		"skin_5_unlocked": Global.skin_5_unlocked,
		"skin_6_unlocked": Global.skin_6_unlocked,
		"skin_7_unlocked": Global.skin_7_unlocked,
		"skin_8_unlocked": Global.skin_8_unlocked,
		"skin_9_unlocked": Global.skin_9_unlocked,
		"skin_10_unlocked": Global.skin_10_unlocked,
		
		"last_daily_reward_time": Global.last_daily_reward_time,
		"pet_rock_broken": Global.pet_rock_broken,
		"bed_buff_time_left": Global.bed_buff_time_left,
		
		"music_volume": Global.music_volume,
		"sfx_volume": Global.sfx_volume,
		
		"village_spawn_pos_x": Global.village_spawn_pos_x,
		"village_spawn_pos_y": Global.village_spawn_pos_y,
		"has_village_spawn": Global.has_village_spawn,
		
		"stat_total_ascensions": Global.stat_total_ascensions,
		"stat_total_money_earned": Global.stat_total_money_earned,
		"stat_total_clicks": Global.stat_total_clicks,
		
		"mining_power": Global.mining_power,
		"mining_speed_level": Global.mining_speed_level,
		"ore_multiplier": Global.ore_multiplier,
		"current_mining_mode": Global.current_mining_mode,
		
		"power_cost": Global.power_cost,
		"speed_cost": Global.speed_cost,
		"mult_cost": Global.mult_cost
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var parse_result = JSON.parse_string(json_string)
		file.close()
		
		if typeof(parse_result) == TYPE_DICTIONARY:
			var data = parse_result
			if data.has("money"): 
				Global.money = data["money"]
				Global.visual_money = Global.money
			if data.has("ascension_coins"): Global.ascension_coins = data["ascension_coins"]
			if data.has("has_stair_compass"): Global.has_stair_compass = data["has_stair_compass"]
			if data.has("has_ore_compass"): Global.has_ore_compass = data["has_ore_compass"]
			if data.has("has_mining_dash"): Global.has_mining_dash = data["has_mining_dash"]
			if data.has("has_midas_luck"): Global.has_midas_luck = data["has_midas_luck"]
			if data.has("has_extra_hit"): Global.has_extra_hit = data["has_extra_hit"]
			if data.has("has_floor_multiplier"): Global.has_floor_multiplier = data["has_floor_multiplier"]
			if data.has("has_shockwave"): Global.has_shockwave = data["has_shockwave"]
			if data.has("has_chain_reaction"): Global.has_chain_reaction = data["has_chain_reaction"]
			
			if data.has("has_boots_1"): Global.has_boots_1 = data["has_boots_1"]
			if data.has("is_boots_active"): Global.is_boots_active = data["is_boots_active"]
			if data.has("has_auto_momentum"): Global.has_auto_momentum = data["has_auto_momentum"]
			if data.has("has_explosive_impact"): Global.has_explosive_impact = data["has_explosive_impact"]
			if data.has("has_supreme_dash"): Global.has_supreme_dash = data["has_supreme_dash"]
			
			if data.has("has_automatic"): Global.has_automatic = data["has_automatic"]
			if data.has("has_alchemical"): Global.has_alchemical = data["has_alchemical"]
			if data.has("has_ticket_minas_lv1"): Global.has_ticket_minas_lv1 = data["has_ticket_minas_lv1"]
			if data.has("has_ticket_minas_lv2"): Global.has_ticket_minas_lv2 = data["has_ticket_minas_lv2"]
			if data.has("has_toque_magico"): Global.has_toque_magico = data["has_toque_magico"]
			
			if data.has("has_juros_compostos"): Global.has_juros_compostos = data["has_juros_compostos"]
			if data.has("has_echo_strike"): Global.has_echo_strike = data["has_echo_strike"]
			if data.has("has_void_gluttony"): Global.has_void_gluttony = data["has_void_gluttony"]
			if data.has("has_cosmic_synergy"): Global.has_cosmic_synergy = data["has_cosmic_synergy"]
			if data.has("has_boomerang"): Global.has_boomerang = data["has_boomerang"]
			if data.has("has_time_warp"): Global.has_time_warp = data["has_time_warp"]
			
			if data.has("is_auto_upgrade_active"): Global.is_auto_upgrade_active = data["is_auto_upgrade_active"]
			if data.has("unlocked_levels"): Global.unlocked_levels = data["unlocked_levels"]
			if data.has("unlocked_furnitures"): Global.unlocked_furnitures = data["unlocked_furnitures"]
			if data.has("equipped_skin_index"): Global.equipped_skin_index = int(data["equipped_skin_index"])
			
			if data.has("skin_1_unlocked"): Global.skin_1_unlocked = data["skin_1_unlocked"]
			if data.has("skin_2_unlocked"): Global.skin_2_unlocked = data["skin_2_unlocked"]
			if data.has("skin_3_unlocked"): Global.skin_3_unlocked = data["skin_3_unlocked"]
			if data.has("skin_4_unlocked"): Global.skin_4_unlocked = data["skin_4_unlocked"]
			if data.has("skin_5_unlocked"): Global.skin_5_unlocked = data["skin_5_unlocked"]
			if data.has("skin_6_unlocked"): Global.skin_6_unlocked = data["skin_6_unlocked"]
			if data.has("skin_7_unlocked"): Global.skin_7_unlocked = data["skin_7_unlocked"]
			if data.has("skin_8_unlocked"): Global.skin_8_unlocked = data["skin_8_unlocked"]
			if data.has("skin_9_unlocked"): Global.skin_9_unlocked = data["skin_9_unlocked"]
			if data.has("skin_10_unlocked"): Global.skin_10_unlocked = data["skin_10_unlocked"]
			
			if data.has("last_daily_reward_time"): Global.last_daily_reward_time = int(data["last_daily_reward_time"])
			if data.has("pet_rock_broken"): Global.pet_rock_broken = data["pet_rock_broken"]
			if data.has("bed_buff_time_left"): Global.bed_buff_time_left = float(data["bed_buff_time_left"])
			
			if data.has("music_volume"): Global.music_volume = float(data["music_volume"])
			if data.has("sfx_volume"): Global.sfx_volume = float(data["sfx_volume"])
			
			if data.has("village_spawn_pos_x"): Global.village_spawn_pos_x = float(data["village_spawn_pos_x"])
			if data.has("village_spawn_pos_y"): Global.village_spawn_pos_y = float(data["village_spawn_pos_y"])
			if data.has("has_village_spawn"): Global.has_village_spawn = data["has_village_spawn"]
			
			if data.has("stat_total_ascensions"): Global.stat_total_ascensions = int(data["stat_total_ascensions"])
			if data.has("stat_total_money_earned"): Global.stat_total_money_earned = int(data["stat_total_money_earned"])
			if data.has("stat_total_clicks"): Global.stat_total_clicks = int(data["stat_total_clicks"])
			
			if data.has("mining_power"): Global.mining_power = int(data["mining_power"])
			if data.has("mining_speed_level"): Global.mining_speed_level = float(data["mining_speed_level"])
			if data.has("ore_multiplier"): Global.ore_multiplier = float(data["ore_multiplier"])
			if data.has("current_mining_mode"): Global.current_mining_mode = int(data["current_mining_mode"])
			
			if data.has("power_cost"): Global.power_cost = int(data["power_cost"])
			if data.has("speed_cost"): Global.speed_cost = int(data["speed_cost"])
			if data.has("mult_cost"): Global.mult_cost = int(data["mult_cost"])

func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("save_data.json")
	
	# Restaura valores padrões
	Global.money = 10000000000000
	Global.visual_money = 1000000000000
	Global.ascension_coins = 10000
	Global.has_stair_compass = false
	Global.has_ore_compass = false
	Global.has_mining_dash = false
	Global.has_midas_luck = false
	Global.has_extra_hit = false
	Global.has_floor_multiplier = false
	Global.has_shockwave = false
	Global.has_chain_reaction = false
	
	Global.has_boots_1 = false
	Global.is_boots_active = false
	Global.has_auto_momentum = false
	Global.has_explosive_impact = false
	Global.has_supreme_dash = false
	
	Global.has_automatic = false
	Global.has_alchemical = false
	Global.has_ticket_minas_lv1 = false
	Global.has_ticket_minas_lv2 = false
	Global.has_toque_magico = false
	
	Global.has_juros_compostos = false
	Global.has_echo_strike = false
	Global.has_void_gluttony = false
	Global.has_cosmic_synergy = false
	Global.has_boomerang = false
	Global.has_time_warp = false
	
	Global.is_auto_upgrade_active = false
	Global.unlocked_levels.clear()
	Global.unlocked_furnitures.clear()
	Global.equipped_skin_index = -1
	
	Global.skin_1_unlocked = false
	Global.skin_2_unlocked = false
	Global.skin_3_unlocked = false
	Global.skin_4_unlocked = false
	Global.skin_5_unlocked = false
	Global.skin_6_unlocked = false
	Global.skin_7_unlocked = false
	Global.skin_8_unlocked = false
	Global.skin_9_unlocked = false
	Global.skin_10_unlocked = false
	Global.has_village_spawn = false
	Global.village_spawn_pos_x = 0.0
	Global.village_spawn_pos_y = 0.0
	
	Global.stat_total_ascensions = 0
	Global.stat_total_money_earned = 0
	Global.stat_total_clicks = 0
	
	# Os volumes não são resetados!
	# (Global.music_volume e Global.sfx_volume mantêm o valor atual)
	
	Global.mining_power = 1
	Global.mining_speed_level = 1.0
	Global.ore_multiplier = 1.0
	Global.current_mining_mode = 0
	
	Global.power_cost = 10
	Global.speed_cost = 10
	Global.mult_cost = 10
	
	get_tree().change_scene_to_file("res://main_scene.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
