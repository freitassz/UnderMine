extends Interactable

@export_file("*.tscn") var target_scene: String = "res://main_scene.tscn"

func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	if target_scene != "":
		# Salva o jogo antes de trocar de cena
		SaveManager.save_game()
		get_tree().change_scene_to_file(target_scene)
