extends Interactable
func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	if Global.bed_buff_time_left > 0: return
	Global.bed_buff_time_left = 600.0
	SaveManager.save_game()
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].update_stats()
	
	var flash = ColorRect.new()
	flash.color = Color(0, 0, 0, 1)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.custom_minimum_size = Vector2(10000, 10000)
	flash.position = -Vector2(5000, 5000)
	var root = get_tree().current_scene
	if not root: root = get_tree().root
	root.add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 1.5)
	tween.tween_callback(flash.queue_free)
