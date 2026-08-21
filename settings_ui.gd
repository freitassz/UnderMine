extends Panel

@onready var exit_btn = $VBoxContainer/ExitButton
@onready var reset_btn = $VBoxContainer/ResetButton
@onready var auto_upgrade_btn = $VBoxContainer/AutoUpgradeBtn
@onready var music_slider = $VBoxContainer/MusicSlider
@onready var sfx_slider = $VBoxContainer/SFXSlider
@onready var close_btn = $VBoxContainer/TopBar/CloseBtn
@onready var confirm_dialog = $ConfirmDialog

func _ready() -> void:
	hide()
	close_btn.pressed.connect(hide)
	exit_btn.pressed.connect(_on_exit_pressed)
	
	reset_btn.pressed.connect(_on_reset_pressed)
	confirm_dialog.confirmed.connect(_on_confirm_reset)
	
	auto_upgrade_btn.toggled.connect(_on_auto_upgrade_toggled)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)

func open() -> void:
	# Atualiza o estado do botão ao abrir o menu
	auto_upgrade_btn.button_pressed = Global.is_auto_upgrade_active
	music_slider.value = Global.music_volume
	sfx_slider.value = Global.sfx_volume
	show()

func _on_music_changed(val: float) -> void:
	Global.music_volume = val
	AudioServer.set_bus_volume_db(1, linear_to_db(val))
	
func _on_sfx_changed(val: float) -> void:
	Global.sfx_volume = val
	AudioServer.set_bus_volume_db(2, linear_to_db(val))

func _on_auto_upgrade_toggled(button_pressed: bool) -> void:
	Global.is_auto_upgrade_active = button_pressed

func _on_reset_pressed() -> void:
	confirm_dialog.popup_centered()

func _on_confirm_reset() -> void:
	SaveManager.reset_save()

func _on_exit_pressed() -> void:
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://main_scene.tscn")
