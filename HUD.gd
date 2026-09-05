extends CanvasLayer

@onready var money_label: Label = $MoneyLabel
var ascension_label: Label

var upgrades_ui_scene = preload("res://upgrades_ui.tscn")
var upgrades_ui: Control
var upgrades_btn: Button

var settings_ui_scene = preload("res://settings_ui.tscn")
var settings_ui: Control
var settings_btn: Button

var mult_label: Label
var active_ability_btn: Button
var time_warp_btn: Button
var time_warp_cooldown: float = 0.0

func _ready() -> void:
	# Atualiza o texto logo que o jogo começa com o valor inicial
	_update_money_text(Global.money)
	
	ascension_label = Label.new()
	ascension_label.position = Vector2(0, 20)
	ascension_label.add_theme_color_override("font_color", Color(0.8, 0.4, 1.0))
	add_child(ascension_label)
	_update_ascension_text(Global.ascension_coins)
	
	# Conecta o sinal do Autoload para atualizar automaticamente sempre que ganhar dinheiro
	Global.money_changed.connect(_update_money_text)
	Global.ascension_coins_changed.connect(_update_ascension_text)

	# Cria o botão de Melhorias
	upgrades_btn = Button.new()
	upgrades_btn.text = "Melhorias"
	upgrades_btn.position = Vector2(0, 45) # Abaixo do dinheiro
	add_child(upgrades_btn)
	
	# Cria o botão de Habilidade Ativa
	active_ability_btn = Button.new()
	active_ability_btn.position = Vector2(0, 120)
	active_ability_btn.pressed.connect(_on_active_ability_pressed)
	add_child(active_ability_btn)
	
	time_warp_btn = Button.new()
	time_warp_btn.position = Vector2(0, 160)
	time_warp_btn.pressed.connect(_on_time_warp_pressed)
	add_child(time_warp_btn)
	
	# Instancia a interface de Melhorias
	upgrades_ui = upgrades_ui_scene.instantiate()
	add_child(upgrades_ui)
	upgrades_btn.pressed.connect(upgrades_ui.open)

	# Cria o Label do multiplicador
	mult_label = Label.new()
	mult_label.text = "Velocidade: 1.0x"
	mult_label.position = Vector2(0, 85)
	add_child(mult_label)

	# Cria o botão de Configurações
	settings_btn = Button.new()
	settings_btn.text = "Config"
	settings_btn.position = Vector2(get_viewport().get_visible_rect().size.x - 80, 10)
	add_child(settings_btn)
	
	# Instancia a interface de Configurações
	settings_ui = settings_ui_scene.instantiate()
	add_child(settings_ui)
	settings_btn.pressed.connect(settings_ui.open)
	
	# --- INÍCIO CÓDIGO DEBUG (Pode apagar no futuro) ---
	var debug_screen = preload("res://debug_screen.gd").new()
	add_child(debug_screen)
	# --- FIM CÓDIGO DEBUG ---
	
	call_deferred("_connect_player")

func _process(_delta: float) -> void:
	if Global.current_mining_mode == 3: # AUTOMATIC
		active_ability_btn.show()
		if Global.is_afk_active:
			active_ability_btn.text = "AFK: LIGADO"
			active_ability_btn.modulate = Color(0, 1, 0)
		else:
			active_ability_btn.text = "AFK: DESLIGADO"
			active_ability_btn.modulate = Color(1, 1, 1)
	elif Global.current_mining_mode == 4: # ALCHEMICAL
		active_ability_btn.show()
		active_ability_btn.text = "Transmutar Minério"
		active_ability_btn.modulate = Color(1, 0.5, 1)
	else:
		active_ability_btn.hide()
		
	if Global.has_time_warp:
		time_warp_btn.show()
		if time_warp_cooldown > 0:
			time_warp_cooldown -= _delta
			time_warp_btn.text = "Time Warp (" + str(int(time_warp_cooldown)) + "s)"
			time_warp_btn.disabled = true
		else:
			time_warp_btn.text = "Ativar Time Warp (5min AFK)"
			time_warp_btn.disabled = false
	else:
		time_warp_btn.hide()

func _on_time_warp_pressed() -> void:
	if time_warp_cooldown > 0: return
	time_warp_cooldown = 300.0 # 5 minutes
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0: return
	var p = players[0]
	
	var ores = get_tree().get_nodes_in_group("ores")
	var nearest_ore = null
	var min_dist = 999999.0
	for o in ores:
		var d = p.global_position.distance_to(o.global_position)
		if d < min_dist:
			min_dist = d
			nearest_ore = o
			
	if nearest_ore and nearest_ore.my_data:
		var spd = Global.mining_speed_level
		# 60 segundos * 5 minutos = 300 segundos
		# Batidas por segundo = 1.0 / (BASE_MINE_TIME / spd) = spd
		var total_hits = 300.0 * spd
		
		# Ganho total (ignorando vidas porque no endgame a pedra tem muitas vidas, 
		# vamos simplificar simulando o ganho bruto que ele faria batendo nela)
		var money_per_hit = nearest_ore.my_data.money_drop * Global.get_effective_mult()
		# Reduz em 50% igual o AFK
		var total_money = int(total_hits * money_per_hit * 0.5)
		
		if Global.has_midas_luck:
			total_money = int(total_money * 1.15) # +15% na media
			
		Global.add_money(total_money)
		Global.apply_visual_money(total_money)
		
		var flash = ColorRect.new()
		flash.color = Color(0.5, 0.5, 1.0, 0.5) # Azul
		flash.set_anchors_preset(Control.PRESET_FULL_RECT)
		flash.custom_minimum_size = Vector2(10000, 10000)
		flash.position = -Vector2(5000, 5000)
		get_tree().root.add_child(flash)
		var tween = create_tween()
		tween.tween_property(flash, "modulate:a", 0.0, 1.0)
		tween.tween_callback(flash.queue_free)

func _on_active_ability_pressed() -> void:
	if Global.current_mining_mode == 3: # AUTOMATIC
		Global.is_afk_active = not Global.is_afk_active
	elif Global.current_mining_mode == 4: # ALCHEMICAL
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			players[0].use_alchemical()

func _connect_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].multiplier_changed.connect(_update_multiplier)

func _update_multiplier(mult: float) -> void:
	if mult > 1.0:
		mult_label.text = "Velocidade: " + str(snapped(mult, 0.01)) + "x!!"
		mult_label.modulate = Color(1, 0.8, 0) # Dourado quando tiver bônus
	else:
		mult_label.text = "Velocidade: 1.0x"
		mult_label.modulate = Color(1, 1, 1)

# Função que formata e exibe o texto na tela
func _update_money_text(new_amount: int) -> void:
	money_label.text = "Moedas: " + Global.format_num(new_amount)

func _update_ascension_text(new_amount: int) -> void:
	if new_amount > 0:
		ascension_label.show()
		ascension_label.text = "Moedas de Ascensão: " + Global.format_num(new_amount)
	else:
		ascension_label.hide()
