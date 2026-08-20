extends CanvasLayer

@onready var money_label: Label = $MoneyLabel

var upgrades_ui_scene = preload("res://upgrades_ui.tscn")
var upgrades_ui: Control
var upgrades_btn: Button

var settings_ui_scene = preload("res://settings_ui.tscn")
var settings_ui: Control
var settings_btn: Button

var mult_label: Label
var active_ability_btn: Button

func _ready() -> void:
	# Atualiza o texto logo que o jogo começa com o valor inicial
	_update_money_text(Global.money)
	
	# Conecta o sinal do Autoload para atualizar automaticamente sempre que ganhar dinheiro
	Global.money_changed.connect(_update_money_text)

	# Cria o botão de Melhorias
	upgrades_btn = Button.new()
	upgrades_btn.text = "Melhorias"
	upgrades_btn.position = Vector2(0, 30) # Abaixo do dinheiro
	add_child(upgrades_btn)
	
	# Cria o botão de Habilidade Ativa
	active_ability_btn = Button.new()
	active_ability_btn.position = Vector2(0, 100)
	active_ability_btn.pressed.connect(_on_active_ability_pressed)
	add_child(active_ability_btn)
	
	# Instancia a interface de Melhorias
	upgrades_ui = upgrades_ui_scene.instantiate()
	add_child(upgrades_ui)
	upgrades_btn.pressed.connect(upgrades_ui.open)

	# Cria o Label do multiplicador
	mult_label = Label.new()
	mult_label.text = "Velocidade: 1.0x"
	mult_label.position = Vector2(0, 70)
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
	money_label.text = "Moedas: " + str(new_amount)
