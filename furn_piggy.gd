extends Interactable
func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	var current_time = int(Time.get_unix_time_from_system())
	var hours_passed = (current_time - Global.last_daily_reward_time) / 3600.0
	if hours_passed >= 24.0 or Global.last_daily_reward_time == 0:
		Global.last_daily_reward_time = current_time
		var reward = Global.get_effective_power() * 10000
		Global.add_money(reward)
		Global.apply_visual_money(reward)
		SaveManager.save_game()
		var lbl = Label.new()
		lbl.text = "DIA! +" + Global.format_num(reward)
		lbl.add_theme_color_override("font_color", Color.PINK)
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.global_position = global_position - Vector2(10, 20)
		var root = get_tree().current_scene
		if not root: root = get_tree().root
		root.add_child(lbl)
		var t = create_tween()
		t.tween_property(lbl, "global_position", lbl.global_position - Vector2(0, 30), 1.0)
		t.parallel().tween_property(lbl, "modulate:a", 0.0, 1.0)
		t.tween_callback(lbl.queue_free)
		
		# Som
		var sfx = AudioStreamPlayer2D.new()
		sfx.stream = preload("res://pickupCoin.wav")
		sfx.bus = "SFX"
		sfx.global_position = global_position
		root.add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)
