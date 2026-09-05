extends Interactable
func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	# Apenas dá um play na música de novo ou toca a prox (no futuro)
	if Global.bgm_player:
		Global.bgm_player.stop()
		Global.bgm_player.play()
	
	var lbl = Label.new()
	lbl.text = "Tocando: JubsMenu"
	lbl.add_theme_color_override("font_color", Color.CYAN)
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.global_position = global_position - Vector2(30, 20)
	var root = get_tree().current_scene
	if not root: root = get_tree().root
	root.add_child(lbl)
	var t = create_tween()
	t.tween_property(lbl, "global_position", lbl.global_position - Vector2(0, 30), 1.0)
	t.parallel().tween_property(lbl, "modulate:a", 0.0, 1.0)
	t.tween_callback(lbl.queue_free)
