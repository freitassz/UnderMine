class_name Interactable extends Area2D

# Criamos um sinal personalizado para avisar o Player quem foi clicado e onde está
signal object_clicked(target_node: Node2D, target_pos: Vector2)

func _ready() -> void:
	# Conecta o sinal nativo do Godot de quando o mouse/toque interage com a colisão
	input_event.connect(_on_input_event)

# Função chamada automaticamente pelo Godot quando clicamos/tocamos dentro do CollisionShape
# Função chamada automaticamente pelo Godot quando clicamos/tocamos dentro do CollisionShape
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# Busca a lista de nós que estão no grupo "player"
		var player_nodes = get_tree().get_nodes_in_group("player")
		
		# Se encontrou o jogador, manda ele vir até a pedra
		if player_nodes.size() > 0:
			var player = player_nodes[0]
			# Chama a função de andar direto no jogador, passando o próprio objeto (self)
			player.walk_to_interact(self)
		
		# Dizemos para a engine que esse clique já foi processado
		get_viewport().set_input_as_handled()

# Essa função será sobrescrita pelos objetos específicos (Pedra, Loja, etc)
func interact() -> void:
	pass
