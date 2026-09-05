extends Interactable

@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var skins_list: VBoxContainer = $CanvasLayer/Panel/VBoxContainer/ScrollContainer/SkinsList
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
	build_skins_list()

func build_skins_list() -> void:
	# Limpa a lista atual
	for child in skins_list.get_children():
		child.queue_free()
		
	var found_any = false
	
	# Botão para equipar a Skin Padrão
	var def_hbox = HBoxContainer.new()
	var def_lbl = Label.new()
	def_lbl.text = "Skin Padrão"
	def_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	def_hbox.add_child(def_lbl)
	
	var def_btn = Button.new()
	if Global.equipped_skin_index == -1:
		def_btn.text = "Equipado"
		def_btn.disabled = true
	else:
		def_btn.text = "Equipar"
		def_btn.disabled = false
	def_btn.pressed.connect(_on_equip_pressed.bind(-1))
	def_hbox.add_child(def_btn)
	skins_list.add_child(def_hbox)
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0: return
	var p = players[0]
	var player_skins = p.skins
	
	# Loop sobre todas as skins
	for i in range(player_skins.size()):
		var tex = player_skins[i]
		if tex == null: continue
		
		# Verifica a variável de desbloqueio com base no índice 0 a 9
		var is_unlocked = false
		match i:
			0: is_unlocked = Global.skin_1_unlocked
			1: is_unlocked = Global.skin_2_unlocked
			2: is_unlocked = Global.skin_3_unlocked
			3: is_unlocked = Global.skin_4_unlocked
			4: is_unlocked = Global.skin_5_unlocked
			5: is_unlocked = Global.skin_6_unlocked
			6: is_unlocked = Global.skin_7_unlocked
			7: is_unlocked = Global.skin_8_unlocked
			8: is_unlocked = Global.skin_9_unlocked
			9: is_unlocked = Global.skin_10_unlocked
		
		if is_unlocked:
			found_any = true
			var hbox = HBoxContainer.new()
			
			var lbl = Label.new()
			# Adiciona um ícone na label (ou você pode colocar um TextureRect separado)
			lbl.text = "Skin " + str(i + 1)
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(lbl)
			
			var btn = Button.new()
			if Global.equipped_skin_index == i:
				btn.text = "Equipado"
				btn.disabled = true
			else:
				btn.text = "Equipar"
				btn.disabled = false
				
			btn.pressed.connect(_on_equip_pressed.bind(i))
			hbox.add_child(btn)
			
			skins_list.add_child(hbox)
			
	if not found_any:
		var lbl = Label.new()
		lbl.text = "Nenhuma skin extra desbloqueada ainda!"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		skins_list.add_child(lbl)

func _on_equip_pressed(index: int) -> void:
	Global.equipped_skin_index = index
	SaveManager.save_game()
	
	# Atualiza o player na hora!
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		if index == -1 or index >= p.skins.size():
			p.apply_skin(null) # Reseta pra default
		else:
			p.apply_skin(p.skins[index])
			
	build_skins_list()

func _on_close_pressed() -> void:
	is_ui_open = false
	ui_layer.hide()
