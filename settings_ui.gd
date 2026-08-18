extends Panel

@onready var exit_btn = $VBoxContainer/ExitButton
@onready var close_btn = $VBoxContainer/TopBar/CloseBtn

func _ready() -> void:
	hide()
	close_btn.pressed.connect(hide)
	exit_btn.pressed.connect(_on_exit_pressed)

func open() -> void:
	show()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://main_scene.tscn")
