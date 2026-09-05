extends Interactable
var accumulated_damage: int = 0
var dps_timer: float = 1.0

func _process(delta: float) -> void:
	if accumulated_damage > 0:
		dps_timer -= delta
		if dps_timer <= 0:
			_show_dps()

func take_damage(power: int, mult: float, _main: bool = true) -> void:
	accumulated_damage += power
	
	# Efeito de hit
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(0.8, 1.2), 0.05)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.05)
	
	# Som
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = preload("res://stonehit.wav")
	if sfx.stream:
		sfx.bus = "SFX"
		sfx.volume_db = -10.0
		sfx.pitch_scale = randf_range(1.2, 1.5)
		add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)

func _show_dps() -> void:
	var lbl = Label.new()
	lbl.text = "DPS: " + Global.format_num(accumulated_damage)
	lbl.add_theme_color_override("font_color", Color(1, 0.4, 0))
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.global_position = global_position - Vector2(20, 20)
	
	var root = get_tree().current_scene
	if not root: root = get_tree().root
	root.add_child(lbl)
	
	var tw = create_tween()
	tw.tween_property(lbl, "global_position", lbl.global_position - Vector2(0, 30), 1.0)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 1.0)
	tw.tween_callback(lbl.queue_free)
	
	accumulated_damage = 0
	dps_timer = 1.0
