extends Node

const SAVE_PATH = "user://save_data.json"

func _ready() -> void:
	load_game()

func save_game() -> void:
	var save_data = {
		"money": Global.money,
		"has_stair_compass": Global.has_stair_compass,
		"has_ore_compass": Global.has_ore_compass,
		"has_mining_dash": Global.has_mining_dash,
		"has_midas_luck": Global.has_midas_luck,
		"has_shockwave": Global.has_shockwave,
		"has_chain_reaction": Global.has_chain_reaction,
		"has_automatic": Global.has_automatic,
		"has_alchemical": Global.has_alchemical,
		
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
			if data.has("money"): Global.money = data["money"]
			if data.has("has_stair_compass"): Global.has_stair_compass = data["has_stair_compass"]
			if data.has("has_ore_compass"): Global.has_ore_compass = data["has_ore_compass"]
			if data.has("has_mining_dash"): Global.has_mining_dash = data["has_mining_dash"]
			if data.has("has_midas_luck"): Global.has_midas_luck = data["has_midas_luck"]
			if data.has("has_shockwave"): Global.has_shockwave = data["has_shockwave"]
			if data.has("has_chain_reaction"): Global.has_chain_reaction = data["has_chain_reaction"]
			if data.has("has_automatic"): Global.has_automatic = data["has_automatic"]
			if data.has("has_alchemical"): Global.has_alchemical = data["has_alchemical"]
			
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
	Global.money = 10000
	Global.has_stair_compass = false
	Global.has_ore_compass = false
	Global.has_mining_dash = false
	Global.has_midas_luck = false
	Global.has_shockwave = false
	Global.has_chain_reaction = false
	Global.has_automatic = false
	Global.has_alchemical = false
	
	Global.mining_power = 1
	Global.mining_speed_level = 1.0
	Global.ore_multiplier = 1.0
	Global.current_mining_mode = 0
	
	Global.power_cost = 10
	Global.speed_cost = 20
	Global.mult_cost = 50
	
	get_tree().change_scene_to_file("res://main_scene.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
