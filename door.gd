extends Interactable
 
@export var cost: int = 100
@export var is_level_door: bool = false
@export var level_name: String = "Mina Oculta"

@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var cost_label: Label = $CanvasLayer/Panel/VBoxContainer/CostLabel
@onready var yes_btn: Button = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/YesBtn
@onready var no_btn: Button = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/NoBtn
 
var is_ui_open: bool = false
 
func _ready() -> void:
	super._ready() # Chama o _ready de Interactable para conectar o clique
	
	if is_level_door and Global.unlocked_levels.has(name):
		queue_free()
		return
		
	ui_layer.hide()
	yes_btn.pressed.connect(_on_yes_pressed)
	no_btn.pressed.connect(_on_no_pressed)
	cost_label.text = "Abrir por " + str(cost) + " moedas?"
 
# Quando o player chega e dá o primeiro "hit", a gente abre a interface
func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	# Faz o player parar de bater na porta
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		p.change_state(p.State.IDLE)
		p.interact_target = null

	if is_level_door:
		# Portas de level só são abertas pelo LevelShop, então não faz nada ao bater nelas
		return
		
	if is_ui_open: return
	open_ui()
 
func open_ui() -> void:
	is_ui_open = true
	ui_layer.show()
	
	# Habilita ou desabilita o botão Yes baseado no dinheiro
	yes_btn.disabled = Global.money < cost
 
func _on_yes_pressed() -> void:
	if Global.money >= cost:
		Global.add_money(-cost)
		# Deleta a porta
		queue_free()
 
func _on_no_pressed() -> void:
	is_ui_open = false
	ui_layer.hide()
