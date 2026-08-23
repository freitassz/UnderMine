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

var spinning: bool = false
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
	
	_randomize_slots()
	update_ui()

func update_ui() -> void:
	if cost_label:
		cost_label.text = "Custo: " + Global.format_num(spin_cost)

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
			
			# Troca a imagem rapidamente para simular giro
			if timers[i] >= current_speeds[i]:
				timers[i] = 0.0
				var slot = [slot1, slot2, slot3][i]
				slot.texture = slot_images[randi() % slot_images.size()]
				
			# Vai diminuindo a velocidade antes de parar
			if stop_delays[i] < 1.0:
				current_speeds[i] += delta * 0.1
		else:
			# Esse slot já parou
			pass

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
	if slot1.texture == slot2.texture and slot2.texture == slot3.texture:
		result_label.text = "VOCÊ GANHOU!"
		result_label.modulate = Color(0, 1, 0) # Verde
		# Aqui você pode dar o prêmio pro jogador no futuro
	else:
		result_label.text = "Tente Novamente!"
		result_label.modulate = Color(1, 0, 0) # Vermelho
