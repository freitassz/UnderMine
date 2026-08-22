extends CanvasLayer

var label: Label
var save_btn: Button
var load_btn: Button
var f3_was_pressed: bool = false

# Dicionário para guardar o save temporário de debug
var temp_save_data = {}

func _ready() -> void:
	layer = 120 # Fica por cima de toda a UI normal
	
	label = Label.new()
	# Posiciona no canto superior esquerdo, abaixo de algumas UIs ou mais no meio da tela
	label.position = Vector2(10, 200) 
	label.add_theme_color_override("font_color", Color(1, 1, 0, 1))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.add_theme_constant_override("outline_size", 2)
	label.hide() # Começa escondido
	add_child(label)
	
	# Criando botões de Save/Load Temporário
	save_btn = Button.new()
	save_btn.text = "[DEBUG] Salvar Estado"
	save_btn.position = Vector2(10, 480)
	save_btn.hide()
	save_btn.pressed.connect(_on_save_temp_pressed)
	add_child(save_btn)
	
	load_btn = Button.new()
	load_btn.text = "[DEBUG] Carregar Estado"
	load_btn.position = Vector2(10, 520)
	load_btn.hide()
	load_btn.pressed.connect(_on_load_temp_pressed)
	add_child(load_btn)

func _on_save_temp_pressed() -> void:
	temp_save_data = {
		"money": Global.money,
		"visual_money": Global.visual_money,
		"ascension_coins": Global.ascension_coins,
		"mining_power": Global.mining_power,
		"mining_speed_level": Global.mining_speed_level,
		"ore_multiplier": Global.ore_multiplier,
		"power_cost": Global.power_cost,
		"speed_cost": Global.speed_cost,
		"mult_cost": Global.mult_cost,
		"current_mining_mode": Global.current_mining_mode,
		"current_floor_index": Global.current_floor_index,
	}
	print("DEBUG: Estado temporário salvo!")
	# Pisca a cor do botão pra dar feedback
	save_btn.modulate = Color(0, 1, 0)
	var tw = create_tween()
	tw.tween_property(save_btn, "modulate", Color(1, 1, 1), 0.5)

func _on_load_temp_pressed() -> void:
	if temp_save_data.is_empty():
		print("DEBUG: Nenhum save temporário encontrado!")
		return
		
	# Restaurando os valores
	Global.money = temp_save_data["money"]
	Global.visual_money = temp_save_data["visual_money"]
	Global.ascension_coins = temp_save_data["ascension_coins"]
	Global.mining_power = temp_save_data["mining_power"]
	Global.mining_speed_level = temp_save_data["mining_speed_level"]
	Global.ore_multiplier = temp_save_data["ore_multiplier"]
	Global.power_cost = temp_save_data["power_cost"]
	Global.speed_cost = temp_save_data["speed_cost"]
	Global.mult_cost = temp_save_data["mult_cost"]
	Global.current_mining_mode = temp_save_data["current_mining_mode"]
	Global.current_floor_index = temp_save_data["current_floor_index"]
	
	# Disparando sinais para a HUD atualizar
	Global.money_changed.emit(Global.visual_money)
	Global.ascension_coins_changed.emit(Global.ascension_coins)
	Global._trigger_player_levelup()
	
	# Pisca o botão para dar feedback
	load_btn.modulate = Color(0, 1, 0)
	var tw = create_tween()
	tw.tween_property(load_btn, "modulate", Color(1, 1, 1), 0.5)
	
	print("DEBUG: Estado temporário carregado com sucesso!")

func _process(_delta: float) -> void:
	# Toggle com a tecla F3
	var f3_pressed = Input.is_key_pressed(KEY_F3)
	if f3_pressed and not f3_was_pressed:
		label.visible = not label.visible
		save_btn.visible = label.visible
		load_btn.visible = label.visible
	f3_was_pressed = f3_pressed
			
	if not label.visible:
		return
		
	var fps = Engine.get_frames_per_second()
	var damage = Global.mining_power
	
	var players = get_tree().get_nodes_in_group("player")
	var click_mult = 1.0
	var wait_time = 1.0
	var current_state = "Desconhecido"
	var speed = 0.0
	
	if players.size() > 0:
		var p = players[0]
		if "click_multiplier" in p:
			click_mult = p.click_multiplier
		if p.has_node("MiningTimer"):
			var timer = p.get_node("MiningTimer")
			wait_time = max(0.001, timer.wait_time)
		if "current_state" in p:
			var states = ["IDLE", "MOVING", "MOVING_TO_INTERACT", "MINING", "LEAPING"]
			if p.current_state >= 0 and p.current_state < states.size():
				current_state = states[p.current_state]
			else:
				current_state = str(p.current_state)
		if "speed" in p:
			speed = p.speed
			
	var hits_per_sec = 1.0 / wait_time
	var dps = float(damage) * hits_per_sec
	var money_mult = Global.ore_multiplier
	
	var text = "--- DEBUG (F3) ---\n"
	text += "FPS: %d\n" % fps
	text += "Dano por Hit: %d\n" % damage
	text += "DPS: %.2f\n" % dps
	text += "Velocidade de Ataque: %.2f hits/s (Delay: %.2fs)\n" % [hits_per_sec, wait_time]
	text += "Multiplicador de Grana: %.2fx\n" % money_mult
	text += "Multiplicador (Clique): %.2fx\n" % click_mult
	text += "Velocidade (Movimento): %.1f\n" % speed
	text += "Estado Player: %s\n" % current_state
	text += "Modo Mineração: %d\n" % Global.current_mining_mode
	
	label.text = text
