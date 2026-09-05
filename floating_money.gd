extends Label

var total_amount: int = 0
var timer: float = 0.0
var max_time: float = 0.8
var flying: bool = false
var is_crit: bool = false

# Salva qual pedra gerou o texto, assim sabemos se podemos continuar empilhando
var ore_instance_id: int = 0 

func setup(start_pos: Vector2, ore_id: int) -> void:
	global_position = start_pos - Vector2(20, 8)
	ore_instance_id = ore_id
	add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	add_theme_constant_override("outline_size", 2)

func add_amount(amt: int, crit: bool) -> void:
	total_amount += amt
	if crit:
		is_crit = true
		
	if is_crit:
		text = "CRIT! +" + Global.format_num(total_amount)
		add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
		add_theme_font_size_override("font_size", 16)
	else:
		text = "+" + Global.format_num(total_amount)
		add_theme_color_override("font_color", Color(1, 1, 0, 1))
		add_theme_font_size_override("font_size", 8)
		
	# Efeito de "Pulo" visual na hora que empilha
	var tw = create_tween()
	scale = Vector2(1.5, 1.5)
	tw.tween_property(self, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	timer = max_time # Reseta o timer para ele não voar ainda

func _process(delta: float) -> void:
	if flying: return
	
	timer -= delta
	if timer <= 0:
		fly_to_hud()

func fly_to_hud() -> void:
	flying = true
	
	# Pega a posição aproximada da HUD (canto superior esquerdo)
	var ui_pos = Vector2(10, 10)
	var camera = get_viewport().get_camera_2d()
	if camera:
		ui_pos = camera.get_screen_center_position() - (get_viewport_rect().size / 2.0 / camera.zoom) + Vector2(10, 10)
		
	var tw = create_tween()
	tw.tween_property(self, "global_position", ui_pos, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(self, "scale", Vector2(0.5, 0.5), 0.5)
	
	tw.tween_callback(func():
		# Toca o som da moeda
		var sfx = AudioStreamPlayer.new()
		sfx.stream = preload("res://pickupCoin.wav")
		if sfx.stream:
			sfx.bus = "SFX"
			sfx.volume_db = -10.0 # Abaixa o volume
			sfx.pitch_scale = randf_range(0.9, 1.2)
			var root = get_tree().current_scene
			if not root: root = get_tree().root
			root.add_child(sfx)
			sfx.play()
			sfx.finished.connect(sfx.queue_free)
			
		# Atualiza a HUD visualmente e destrói o texto
		Global.apply_visual_money(total_amount)
		queue_free()
	)
