extends CanvasLayer

@export var spin_cost: int = 500 # Preço de cada giro

var slot_images: Array[Texture2D] = []

@onready var case_rect: TextureRect = $Control/CaseRect
@onready var lever_btn: TextureButton = $Control/LeverBtn
@onready var slot1: TextureRect = $Control/CaseRect/Slot1
@onready var slot2: TextureRect = $Control/CaseRect/Slot2
@onready var slot3: TextureRect = $Control/CaseRect/Slot3
@onready var cost_label: Label = $Control/CostLabel
@onready var close_btn: Button = $Control/CloseBtn
@onready var result_label: Label = $Control/ResultLabel

var debug_btn: Button
var bet_minus_btn: Button
var bet_plus_btn: Button

var available_bets: Array[int] = [50000, 100000, 500000, 1000000, 5000000, 10000000]
var current_bet_index: int = 0

var spinning: bool = false
var target_indices: Array[int] = [0, 0, 0]
var final_prize_multiplier: float = 0.0
var final_is_skin: bool = false
var spin_time_left: float = 0.0
var current_speeds: Array[float] = [0.05, 0.05, 0.05]
var timers: Array[float] = [0.0, 0.0, 0.0]
var stop_delays: Array[float] = [0.0, 0.0, 0.0]

func _ready() -> void:
	hide()
	
	# Carrega as 6 imagens de slots
	slot_images.append(load("res://assets/ores/Slotmachine 1.png"))
	slot_images.append(load("res://assets/Slotmachine 2.png"))
	slot_images.append(load("res://assets/Slotmachine 3.png"))
	slot_images.append(load("res://assets/Slotmachine 4.png"))
	slot_images.append(load("res://assets/Slotmachine5.png"))
	slot_images.append(load("res://assets/Slotmachine 6.png"))
	
	lever_btn.pressed.connect(_on_lever_pressed)
	close_btn.pressed.connect(close)
	
	# Botão de Debug para garantir Jackpot
	debug_btn = Button.new()
	debug_btn.text = "Debug: Force SKIN 6"
	debug_btn.position = Vector2(10, 10)
	debug_btn.pressed.connect(func():
		target_indices = [5, 5, 5]
		final_is_skin = true
		final_prize_multiplier = 0.0
		slot1.texture = slot_images[5]
		slot2.texture = slot_images[5]
		slot3.texture = slot_images[5]
		spinning = false
		lever_btn.disabled = false
		check_result()
	)
	$Control.add_child(debug_btn)
	
	# Botões de Aposta
	bet_minus_btn = Button.new()
	bet_minus_btn.text = "<"
	bet_minus_btn.position = cost_label.position + Vector2(-30, 0)
	bet_minus_btn.pressed.connect(func():
		if current_bet_index > 0: current_bet_index -= 1
		update_ui()
	)
	$Control.add_child(bet_minus_btn)
	
	bet_plus_btn = Button.new()
	bet_plus_btn.text = ">"
	bet_plus_btn.position = cost_label.position + Vector2(cost_label.size.x + 30, 0)
	bet_plus_btn.pressed.connect(func():
		if current_bet_index < available_bets.size() - 1: current_bet_index += 1
		update_ui()
	)
	$Control.add_child(bet_plus_btn)
	
	_randomize_slots()
	update_ui()

func update_ui() -> void:
	spin_cost = available_bets[current_bet_index]
	if cost_label:
		cost_label.text = "Aposta: " + Global.format_num(spin_cost)
	if bet_minus_btn:
		bet_minus_btn.position = cost_label.position + Vector2(-30, 0)
	if bet_plus_btn:
		bet_plus_btn.position = cost_label.position + Vector2(cost_label.size.x + 30, 0)

func open() -> void:
	show()
	result_label.hide()
	lever_btn.disabled = false
	update_ui()

func close() -> void:
	if not spinning:
		hide()

func _on_lever_pressed() -> void:
	if spinning or Global.money < spin_cost:
		return
		
	Global.add_money(-spin_cost)
	update_ui()
	
	spinning = true
	lever_btn.disabled = true
	result_label.hide()
	
	# Calcula o resultado AGORA baseado nas probabilidades
	var roll = randf()
	final_is_skin = false
	final_prize_multiplier = 0.0
	
	if roll <= 0.01:
		# Skin 6 (1%)
		target_indices = [5, 5, 5]
		final_is_skin = true
	elif roll <= 0.02:
		# 10x dinheiro (1%) -> Total = 2%
		target_indices = [3, 3, 3]
		final_prize_multiplier = 10.0
	elif roll <= 0.07:
		# 5x dinheiro (5%) -> Total = 7%
		target_indices = [2, 2, 2]
		final_prize_multiplier = 5.0
	elif roll <= 0.17:
		# 2x dinheiro (10%) -> Total = 17%
		target_indices = [1, 1, 1]
		final_prize_multiplier = 2.0
	elif roll <= 0.37:
		# 1.5x dinheiro (20%) -> Total = 37%
		target_indices = [0, 0, 0]
		final_prize_multiplier = 1.5
	else:
		# Perda (63%)
		target_indices = [randi() % 6, randi() % 6, randi() % 6]
		# Garante que não venham 3 iguais no visual da derrota
		if target_indices[0] == target_indices[1] and target_indices[1] == target_indices[2]:
			target_indices[2] = (target_indices[2] + 1) % 6
	
	# Configura o tempo de parada de cada slot (param um de cada vez)
	stop_delays = [2.0, 3.0, 4.0] 
	current_speeds = [0.05, 0.05, 0.05]

func _process(delta: float) -> void:
	if not spinning:
		return
		
	var all_stopped = true
	
	for i in range(3):
		if stop_delays[i] > 0:
			all_stopped = false
			stop_delays[i] -= delta
			timers[i] += delta
			
			if timers[i] >= current_speeds[i]:
				timers[i] = 0.0
				var slot = [slot1, slot2, slot3][i]
				slot.texture = slot_images[randi() % slot_images.size()]
				
			if stop_delays[i] < 1.0:
				current_speeds[i] += delta * 0.1
		else:
			# Força a textura do alvo final
			var slot = [slot1, slot2, slot3][i]
			slot.texture = slot_images[target_indices[i]]

	if all_stopped:
		spinning = false
		lever_btn.disabled = false
		check_result()

func _randomize_slots() -> void:
	slot1.texture = slot_images[randi() % slot_images.size()]
	slot2.texture = slot_images[randi() % slot_images.size()]
	slot3.texture = slot_images[randi() % slot_images.size()]

func check_result() -> void:
	result_label.show()
	
	if final_is_skin:
		if not Global.skin_6_unlocked:
			Global.skin_6_unlocked = true
			SaveManager.save_game()
			result_label.text = "JACKPOT! Skin Desbloqueada!"
			result_label.modulate = Color(1, 0, 1) # Roxo/Rosa
		else:
			var prize = spin_cost * 20
			Global.add_money(prize)
			result_label.text = "Skin Repetida! Ganhou " + Global.format_num(prize)
			result_label.modulate = Color(0, 1, 0)
	elif final_prize_multiplier > 0.0:
		var prize = int(spin_cost * final_prize_multiplier)
		Global.add_money(prize)
		result_label.text = "GANHOU " + str(final_prize_multiplier) + "x! (+" + Global.format_num(prize) + ")"
		result_label.modulate = Color(0, 1, 0) # Verde
	else:
		result_label.text = "Perdeu! Tente Novamente."
		result_label.modulate = Color(1, 0, 0) # Vermelho
