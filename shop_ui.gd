extends Panel

@onready var close_btn = $VBoxContainer/TopBar/CloseBtn

func _ready() -> void:
	hide()
	close_btn.pressed.connect(hide)
	Global.ore_deselected.connect(hide)

func open() -> void:
	show()
