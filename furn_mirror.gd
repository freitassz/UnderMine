extends Interactable

@onready var ui_layer = $CanvasLayer
@onready var stats_label = $CanvasLayer/Panel/VBoxContainer/StatsLabel
@onready var close_btn = $CanvasLayer/Panel/VBoxContainer/CloseBtn

@onready var sprite = $Sprite2D
var reflection_sprite: Sprite2D = null
var player_node: Node2D = null

var is_ui_open = false

func _ready():
	super._ready()
	ui_layer.hide()
	close_btn.pressed.connect(close_ui)
	
	# Cria um vidro pro espelho para garantir que o reflexo apareça dentro de um quadrado
	var glass = ColorRect.new()
	glass.mouse_filter = Control.MOUSE_FILTER_IGNORE # <-- DEIXA O CLIQUE PASSAR PRO ESPELHO!
	var w = sprite.texture.get_width() / sprite.hframes if sprite.texture else 16
	var h = sprite.texture.get_height() / sprite.vframes if sprite.texture else 24
	glass.size = Vector2(w, h)
	glass.position = -glass.size / 2.0 # Centraliza
	glass.color = Color(0.8, 0.9, 1.0, 0.2) # Vidro meio azulado
	glass.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	sprite.add_child(glass)
	
	reflection_sprite = Sprite2D.new()
	reflection_sprite.modulate = Color(0.8, 0.9, 1.0, 0.8) 
	
	# Adiciona o reflexo DENTRO do vidro, assim ele corta perfeitamente no formato do quadrado!
	glass.add_child(reflection_sprite)

func _process(_delta: float) -> void:
	if not is_instance_valid(player_node):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_node = players[0]
			
	if is_instance_valid(player_node) and is_instance_valid(reflection_sprite):
		var p_sprite = player_node.get_node_or_null("Sprite2D")
		if p_sprite:
			reflection_sprite.texture = p_sprite.texture
			reflection_sprite.hframes = p_sprite.hframes
			reflection_sprite.vframes = p_sprite.vframes
			reflection_sprite.frame = p_sprite.frame
			
			var offset = player_node.global_position - global_position
			
			# Lógica ótica de reflexo num espelho 2D Top-Down
			# A base do espelho é onde o reflexo "toca" o jogador
			var mirror_surface_y = global_position.y + (sprite.texture.get_height() * sprite.scale.y) / 2.0
			var dist_y = player_node.global_position.y - mirror_surface_y
			
			# Posiciona globalmente: X igual ao do player, Y invertido a partir da base do espelho
			reflection_sprite.global_position = Vector2(player_node.global_position.x, mirror_surface_y - dist_y)
			
			# Cancela a distorção do parent
			reflection_sprite.global_scale = p_sprite.global_scale
			
			# Se o player estiver muito para baixo (longe do espelho), 
			# o reflexo vai subir tanto que sai do espelho, 
			# o que o clip_children já resolve cortando a imagem naturalmente!
			
			# Mas se o player estiver "atrás" do espelho (dist_y negativo), escondemos para não aparecer na frente
			if dist_y < -5:
				reflection_sprite.hide()
			else:
				reflection_sprite.show()

func take_damage(p, m, main=true):
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].change_state(players[0].State.IDLE)
		players[0].interact_target = null
	if is_ui_open: return
	
	stats_label.text = "Estatísticas da Jornada\n\n" + \
		"Cliques Manuais: " + Global.format_num(Global.stat_total_clicks) + "\n" + \
		"Moedas Geradas: " + Global.format_num(Global.stat_total_money_earned) + "\n" + \
		"Ascensões (Prestige): " + Global.format_num(Global.stat_total_ascensions)
		
	ui_layer.show()
	is_ui_open = true

func close_ui():
	ui_layer.hide()
	is_ui_open = false
