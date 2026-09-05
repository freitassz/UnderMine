extends Interactable
var hits = 0
func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	if Global.pet_rock_broken: return
	hits += 1
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	var root = get_tree().current_scene
	if not root: root = get_tree().root
	
	if hits >= 100:
		Global.pet_rock_broken = true
		Global.add_ascension_coins(1)
		SaveManager.save_game()
		hide()
		var lbl = Label.new()
		lbl.text = "VOCÊ ENCONTROU UM SEGREDO!"
		lbl.add_theme_color_override("font_color", Color.PURPLE)
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.global_position = global_position - Vector2(50, 20)
		root.add_child(lbl)
		var t2 = create_tween()
		t2.tween_property(lbl, "global_position", lbl.global_position - Vector2(0, 30), 2.0)
		t2.parallel().tween_property(lbl, "modulate:a", 0.0, 2.0)
		t2.tween_callback(lbl.queue_free)
	else:
		var lbl = Label.new()
		var msgs = ["Ai!", "Ei!", "Pode parar", "Isso faz cócegas", "Eu sou uma pedra!"]
		lbl.text = msgs[randi() % msgs.size()]
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.add_theme_font_size_override("font_size", 8)
		lbl.global_position = global_position - Vector2(10, 10)
		root.add_child(lbl)
		var t2 = create_tween()
		t2.tween_property(lbl, "global_position", lbl.global_position - Vector2(0, 20), 0.5)
		t2.parallel().tween_property(lbl, "modulate:a", 0.0, 0.5)
		t2.tween_callback(lbl.queue_free)
