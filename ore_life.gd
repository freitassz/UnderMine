extends CanvasLayer

@export var container: Control
@export var name_label: Label
@export var health_bar: ProgressBar
@export var lives_label: Label

func _ready() -> void:
	# Começa escondido
	container.hide() 
	
	# Conecta os sinais globais às funções deste script
	Global.ore_selected.connect(_on_ore_selected)
	Global.ore_damaged.connect(_on_ore_damaged)
	Global.ore_deselected.connect(_on_ore_deselected)

# Chamado quando clicamos numa pedra
func _on_ore_selected(ore_name: String, max_hp: int, current_hp: int, lives: int) -> void:
	name_label.text = ore_name
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	lives_label.text = "x " + str(lives + 1)
	container.show() # Mostra o HUD

# Chamado a cada batida que damos na pedra
func _on_ore_damaged(current_hp: int, lives: int) -> void:
	health_bar.value = current_hp
	lives_label.text = "x " + str(lives + 1)

# Chamado quando clicamos no chão ou a pedra é destruída
func _on_ore_deselected() -> void:
	container.hide() # Esconde o HUD
