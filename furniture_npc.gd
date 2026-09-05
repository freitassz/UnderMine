extends Interactable

@export var furnitures_for_sale: Array[FurnitureData] = []

@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var furnitures_list: VBoxContainer = $CanvasLayer/Panel/VBoxContainer/ScrollContainer/FurnituresList
@onready var close_btn: Button = $CanvasLayer/Panel/VBoxContainer/CloseBtn

var is_ui_open: bool = false

func _ready() -> void:
	super._ready()
	ui_layer.hide()
	close_btn.pressed.connect(_on_close_pressed)
	
	if furnitures_for_sale.size() == 0:
		furnitures_for_sale.append(load("res://Data/Resource/Furnitures/SlotMachine.tres"))
		furnitures_for_sale.append(load("res://Data/Resource/Furnitures/Wardrobe.tres"))
		furnitures_for_sale.append(load("res://Data/Resource/Furnitures/PiggyBank.tres"))
		furnitures_for_sale.append(load("res://Data/Resource/Furnitures/Bed.tres"))
		furnitures_for_sale.append(load("res://Data/Resource/Furnitures/Jukebox.tres"))
		furnitures_for_sale.append(load("res://Data/Resource/Furnitures/PetRock.tres"))
		furnitures_for_sale.append(load("res://Data/Resource/Furnitures/TrainingDummy.tres"))
		furnitures_for_sale.append(load("res://Data/Resource/Furnitures/SoulMirror.tres"))

func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		p.change_state(p.State.IDLE)
		p.interact_target = null
		
	if is_ui_open: return
	open_ui()

func open_ui() -> void:
	is_ui_open = true
	ui_layer.show()
	build_furnitures_list()

func build_furnitures_list() -> void:
	# Limpa a lista atual
	for child in furnitures_list.get_children():
		child.queue_free()
		
	var found_any = false
	
	for i in range(furnitures_for_sale.size()):
		var data = furnitures_for_sale[i]
		if data == null: continue
		
		# Verifica se já não foi comprado usando o nome do móvel
		if not Global.unlocked_furnitures.has(data.furniture_name):
			found_any = true
			var hbox = HBoxContainer.new()
			
			var lbl = Label.new()
			lbl.text = data.furniture_name + " (" + Global.format_num(data.cost) + " moedas)"
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(lbl)
			
			var btn = Button.new()
			btn.text = "Comprar"
			btn.disabled = Global.money < data.cost
			
			btn.pressed.connect(_on_buy_pressed.bind(data))
			hbox.add_child(btn)
			
			furnitures_list.add_child(hbox)
			
	if not found_any:
		var lbl = Label.new()
		lbl.text = "Todos os móveis foram comprados!"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		furnitures_list.add_child(lbl)

func _on_buy_pressed(data: FurnitureData) -> void:
	if Global.money >= data.cost:
		Global.add_money(-data.cost)
		
		Global.unlocked_furnitures[data.furniture_name] = true
		SaveManager.save_game()
		
		var root = get_tree().current_scene
		if root and root.has_method("spawn_furniture"):
			root.spawn_furniture(data)
			
		build_furnitures_list()

func _on_close_pressed() -> void:
	is_ui_open = false
	ui_layer.hide()
