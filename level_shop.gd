extends Interactable

@export var controlled_doors: Array[NodePath] = []

@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var doors_list: VBoxContainer = $CanvasLayer/Panel/VBoxContainer/ScrollContainer/DoorsList
@onready var close_btn: Button = $CanvasLayer/Panel/VBoxContainer/CloseBtn

var is_ui_open: bool = false

func _ready() -> void:
	super._ready()
	ui_layer.hide()
	close_btn.pressed.connect(_on_close_pressed)

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
	build_doors_list()

func build_doors_list() -> void:
	# Limpa a lista atual
	for child in doors_list.get_children():
		child.queue_free()
		
	var found_any = false
	
	# Cria uma linha para cada porta controlada
	for i in range(controlled_doors.size()):
		var door_path = controlled_doors[i]
		var door = get_node_or_null(door_path)
		
		# Se a porta ainda existe (não foi comprada)
		if is_instance_valid(door) and "is_level_door" in door and door.is_level_door:
			found_any = true
			var hbox = HBoxContainer.new()
			
			var lbl = Label.new()
			var d_name = door.level_name if "level_name" in door else "Porta"
			var d_cost = door.cost if "cost" in door else 100
			lbl.text = d_name + " (" + str(d_cost) + " moedas)"
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(lbl)
			
			var btn = Button.new()
			btn.text = "Comprar"
			btn.disabled = Global.money < d_cost
			
			# Usamos um bind para passar a porta e o botão para a função de compra
			btn.pressed.connect(_on_buy_door_pressed.bind(door, d_cost))
			hbox.add_child(btn)
			
			doors_list.add_child(hbox)
			
	if not found_any:
		var lbl = Label.new()
		lbl.text = "Todos os leveis desbloqueados!"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		doors_list.add_child(lbl)

func _on_buy_door_pressed(door: Node2D, cost: int) -> void:
	if Global.money >= cost:
		Global.add_money(-cost)
		
		if is_instance_valid(door):
			Global.unlocked_levels[door.name] = true
			SaveManager.save_game()
			if door.has_method("play_unlock_animation"):
				door.play_unlock_animation()
			else:
				door.queue_free()
			
		# Fecha a loja pra ver a animação
		_on_close_pressed()

func _on_close_pressed() -> void:
	is_ui_open = false
	ui_layer.hide()