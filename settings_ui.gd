extends Panel

@onready var exit_btn = $VBoxContainer/ExitButton
@onready var reset_btn = $VBoxContainer/ResetButton
@onready var close_btn = $VBoxContainer/TopBar/CloseBtn
@onready var confirm_dialog = $ConfirmDialog

func _ready() -> void:
	hide()
	close_btn.pressed.connect(hide)
	exit_btn.pressed.connect(_on_exit_pressed)
	
	reset_btn.pressed.connect(_on_reset_pressed)
	confirm_dialog.confirmed.connect(_on_confirm_reset)

func open() -> void:
	show()

func _on_reset_pressed() -> void:
	confirm_dialog.popup_centered()

func _on_confirm_reset() -> void:
	SaveManager.reset_save()

func _on_exit_pressed() -> void:
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://main_scene.tscn")
