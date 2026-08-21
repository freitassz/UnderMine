extends CharacterBody2D

# --- VARIÁVEIS DE ESTADO E NAVEGAÇÃO ---
enum State { IDLE, MOVING, MOVING_TO_INTERACT, MINING, LEAPING }
var current_state: State = State.IDLE

enum MiningMode { ORIGINAL, SHOCKWAVE, CHAIN_REACTION, AUTOMATIC, ALCHEMICAL }
@export var shockwave_radius: float = 20.0
@export var chain_reaction_radius: float = 12.0

signal multiplier_changed(mult: float)


# --- STATUS DE MINERAÇÃO (UPGRADES) ---
# Usamos o Global para persistência

const BASE_MINE_TIME: float = 1.0 # Tempo base (1 segundo por batida)
const MIN_MINE_TIME: float = 0.1  # Limite máximo de velocidade (10 batidas por segundo)

@export var speed: float = 200.0
@export var interact_distance: float = 60.0 # Distância para parar antes de bater

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var mining_timer: Timer = $MiningTimer 
@onready var powers_anim: AnimationPlayer = $Powers_Sprite/PowerAnimation
@onready var shockwave_sprite: Sprite2D = $Powers_Sprite/ShockWave
@onready var chain_sprite_base: Sprite2D = $Powers_Sprite/Chain

@export var animated_player: AnimationPlayer

# Alterado de Area2D para Node2D para ser mais genérico na hora de receber o alvo
var interact_target: Node2D = null

var last_hit_time: int = 0
var click_multiplier: float = 1.0
const MAX_CLICK_MULTIPLIER: float = 1.5
const CLICK_MULTIPLIER_STEP: float = 0.01

var stair_arrow: Sprite2D
var ore_arrow: Sprite2D
var target_stair: Node2D
var target_ore: Node2D

func _ready() -> void:
	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 10.0
	
	if mining_timer:
		mining_timer.one_shot = true
		update_stats() # <-- Substitui a definição manual de wait_time
		mining_timer.timeout.connect(_on_mining_timer_timeout)
		
	# Mover para o checkpoint salvo caso esteja na vila
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.scene_file_path == "res://main_scene.tscn":
		if Global.has_village_spawn:
			global_position = Vector2(Global.village_spawn_pos_x, Global.village_spawn_pos_y)
		
	stair_arrow = Sprite2D.new()
	var g_arrow = load("res://assets/Green_Arrow.png")
	if g_arrow: stair_arrow.texture = g_arrow
	stair_arrow.hide()
	stair_arrow.scale = Vector2(1, 1)
	add_child(stair_arrow)
	
	ore_arrow = Sprite2D.new()
	var r_arrow = load("res://assets/Red_arrow.png")
	if r_arrow: ore_arrow.texture = r_arrow
	ore_arrow.hide()
	ore_arrow.scale = Vector2(1, 1)
	add_child(ore_arrow)
		
	change_state(State.IDLE)



func _process(_delta: float) -> void:
	if "has_stair_compass" in Global and Global.has_stair_compass:
		if not is_instance_valid(target_stair):
			var stairs = get_tree().get_nodes_in_group("stairs")
			if stairs.size() > 0:
				target_stair = stairs[0]
		
		if is_instance_valid(target_stair):
			stair_arrow.show()
			stair_arrow.rotation = global_position.direction_to(target_stair.global_position).angle()
			stair_arrow.position = Vector2.RIGHT.rotated(stair_arrow.rotation) * 7.0
		else:
			stair_arrow.hide()
	else:
		if stair_arrow: stair_arrow.hide()
		
	if "has_ore_compass" in Global and Global.has_ore_compass:
		if not is_instance_valid(target_ore):
			_find_best_ore()
			
		if is_instance_valid(target_ore):
			ore_arrow.show()
			ore_arrow.rotation = global_position.direction_to(target_ore.global_position).angle()
			ore_arrow.position = Vector2.RIGHT.rotated(ore_arrow.rotation) * 9.0
		else:
			ore_arrow.hide()
	else:
		if ore_arrow: ore_arrow.hide()
		
	# MODO AUTOMÁTICO (AFK MINING)
	if Global.current_mining_mode == MiningMode.AUTOMATIC and Global.is_afk_active and current_state == State.IDLE:
		_find_nearest_ore_and_mine()

func _find_best_ore() -> void:
	var ores = get_tree().get_nodes_in_group("ores")
	var best_ore = null
	var best_value = -1
	for o in ores:
		if "my_data" in o and o.my_data != null:
			var value = o.my_data.money_drop
			if value > best_value:
				best_value = value
				best_ore = o
	target_ore = best_ore

func _find_nearest_ore_and_mine() -> void:
	var ores = get_tree().get_nodes_in_group("ores")
	var nearest_ore = null
	var min_dist = 999999.0
	for o in ores:
		var d = global_position.distance_to(o.global_position)
		if d < min_dist:
			min_dist = d
			nearest_ore = o
			
	if nearest_ore != null:
		walk_to_interact(nearest_ore)

func update_stats() -> void:
	# Fórmula: Tempo Base dividido pelo Nível de Velocidade e pelo multiplicador de clique manual
	var new_wait_time = (BASE_MINE_TIME / Global.mining_speed_level) / click_multiplier
	
	# max() garante que a velocidade nunca seja menor que o limite (0.1s), evitando quebrar o jogo
	mining_timer.wait_time = max(MIN_MINE_TIME, new_wait_time)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# Cria uma verificação física exatamente onde o mouse clicou
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = get_global_mouse_position()
		query.collide_with_areas = true  # Queremos detectar Area2D (O Minério)
		query.collide_with_bodies = false
		
		# Pega uma lista de tudo que estava embaixo do mouse
		var results = space_state.intersect_point(query)
		
		# Se o clique acertou um Area2D INTERAGÍVEL, paramos o código por aqui e deixamos
		# a função _on_input_event daquele objeto assumir o controle!
		if results.size() > 0:
			for res in results:
				if res.collider is Interactable:
					return
			
		# Se chegou aqui embaixo, significa que bateu no chão livre de verdade (ou num Checkpoint, etc)
		walk_to_point(get_global_mouse_position())

# --- FUNÇÕES DE DEFINIÇÃO DE ALVO ---
func walk_to_point(target_point: Vector2) -> void:
	Global.ore_deselected.emit() # <-- Esconde o HUD pois clicou no chão
	
	# Reseta o multiplicador ao andar para outro lugar
	click_multiplier = 1.0
	multiplier_changed.emit(click_multiplier)
	update_stats()
	
	interact_target = null
	change_state(State.MOVING)
	nav_agent.target_position = target_point
	nav_agent.target_desired_distance = 2.0 
	if mining_timer and !mining_timer.is_stopped():
		mining_timer.stop()

func walk_to_interact(target_node: Node2D) -> void: 
	if interact_target == target_node and current_state == State.MINING:
		# Aumenta o multiplicador de velocidade com base no clique, até o limite
		click_multiplier = min(click_multiplier + CLICK_MULTIPLIER_STEP, MAX_CLICK_MULTIPLIER)
		multiplier_changed.emit(click_multiplier)
		update_stats() # Aplica o novo multiplicador ao timer
		
		# Tenta bater manualmente se o (novo) cooldown já passou
		var current_time = Time.get_ticks_msec()
		var cooldown_ms = int(mining_timer.wait_time * 1000)
		
		if current_time - last_hit_time >= cooldown_ms:
			if mining_timer:
				mining_timer.start() # Reseta o timer para não bater auto em seguida
			_on_mining_timer_timeout()
		return

	# Se clicou num alvo NOVO, reseta o multiplicador
	click_multiplier = 1.0
	multiplier_changed.emit(click_multiplier)
	update_stats()
	interact_target = target_node
	
	# <-- Pede para o minério enviar as informações dele para a tela
	if is_instance_valid(target_node) and target_node.has_method("select_ore"):
		target_node.select_ore()
		
	# CHECAGEM DE ONE-HIT DASH (Apenas se o player comprou a habilidade)
	var will_destroy = false
	if Global.has_mining_dash and "my_data" in target_node and target_node.my_data != null:
		if Global.mining_power >= target_node.my_data.max_hp:
			will_destroy = true
			
	if will_destroy:
		change_state(State.LEAPING)
		velocity = Vector2.ZERO
		nav_agent.target_position = global_position # Para a navegação
		if mining_timer:
			mining_timer.stop()
			
		var dir = global_position.direction_to(target_node.global_position)
		# Pousa um pouquinho antes da pedra (80% da interact_distance)
		var land_pos = target_node.global_position - (dir * (interact_distance * 0.8))
		
		# Dash muito rápido
		var tween = create_tween()
		tween.tween_property(self, "global_position", land_pos, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(func():
			# Chegou! Pode bater
			if current_state == State.LEAPING:
				change_state(State.MINING)
				if mining_timer: mining_timer.start()
				_on_mining_timer_timeout()
		)
	else:
		# Comportamento normal
		change_state(State.MOVING_TO_INTERACT)
		nav_agent.target_position = target_node.global_position
		nav_agent.target_desired_distance = interact_distance 
		if mining_timer and !mining_timer.is_stopped():
			mining_timer.stop()

# --- MÁQUINA DE ESTADOS E MOVIMENTAÇÃO ---
func _physics_process(_delta: float) -> void:
	match current_state:
		State.IDLE, State.MINING, State.LEAPING:
			velocity = Vector2.ZERO
			return
			
		State.MOVING:
			if nav_agent.is_navigation_finished():
				change_state(State.IDLE)
				velocity = Vector2.ZERO
				return
			_process_movement()
			
		State.MOVING_TO_INTERACT:
			# Verifica se o minério ainda existe (pode ter sido quebrado e deletado com queue_free)[cite: 1]
			if is_instance_valid(interact_target):
				var distance = global_position.distance_to(interact_target.global_position)
				
				# Se chegou perto o suficiente, para e começa a minerar
				if distance <= interact_distance:
					change_state(State.MINING)
					velocity = Vector2.ZERO
					if mining_timer:
						mining_timer.start()
						# Ao invés de bater cego, checamos o cooldown para evitar spam exploit
						var current_time = Time.get_ticks_msec()
						var cooldown_ms = int(mining_timer.wait_time * 1000)
						if current_time - last_hit_time >= cooldown_ms:
							mining_timer.start()
							_on_mining_timer_timeout()
						else:
							# Aguarda apenas o tempo que falta para o próximo hit!
							var remaining = (cooldown_ms - (current_time - last_hit_time)) / 1000.0
							mining_timer.start(max(0.01, remaining))
					return
				else:
					# Continua andando até a pedra
					_process_movement()
			else:
				# O minério foi destruído antes do jogador chegar[cite: 1]
				change_state(State.IDLE)
				velocity = Vector2.ZERO

func _process_movement() -> void:
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * speed
	
	# Opcional: Se quiser espelhar a sprite ao andar para a esquerda/direita, descomente o código abaixo:
	# if has_node("Sprite2D"): # Mude para o nome exato da sua Sprite
	#     if new_velocity.x != 0:
	#         $Sprite2D.flip_h = new_velocity.x < 0
	
	# Usa o sistema de Avoidance se ativado
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		velocity = new_velocity
		move_and_slide()

# --- SINAL DO AVOIDANCE ---
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if current_state in [State.MOVING, State.MOVING_TO_INTERACT]:
		velocity = safe_velocity
		move_and_slide()

# --- HABILIDADE ATIVA: ALQUIMIA ---
func use_alchemical() -> void:
	var ores = get_tree().get_nodes_in_group("ores")
	var nearest_ore = null
	var min_dist = 999999.0
	for o in ores:
		var d = global_position.distance_to(o.global_position)
		if d < min_dist:
			min_dist = d
			nearest_ore = o
			
	if is_instance_valid(nearest_ore):
		var ore_layer = get_tree().get_first_node_in_group("ore_layer")
		if ore_layer:
			var mine_scene = ore_layer.get_parent()
			if mine_scene and "current_floor_data" in mine_scene:
				var floor_data = mine_scene.current_floor_data
				if floor_data and floor_data.ore_set:
					var new_ore_data = ore_layer._pick_random_ore(floor_data.ore_set)
					if new_ore_data and nearest_ore.has_method("setup"):
						nearest_ore.setup(new_ore_data)
						nearest_ore.has_been_transmuted = true
						
						# Efeito visual de Flash Branco NA PEDRA
						if nearest_ore.has_node("Sprite2D"):
							var sprite = nearest_ore.get_node("Sprite2D")
							var tween = create_tween()
							sprite.modulate = Color(2, 2, 2, 1) # Modulate branco estourado
							tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.3)

# --- CHAIN REACTION LOGIC ---
func _process_chain_reaction(start_ore: Node2D, multiplier: float) -> void:
	if not is_instance_valid(start_ore): return
	
	var tree = get_tree()
	if not tree: return
	
	var all_ores = tree.get_nodes_in_group("ores")
	var to_process = [start_ore]
	var processed = []
	
	while to_process.size() > 0:
		var current = to_process.pop_front()
		processed.append(current)
		
		for other in all_ores:
			if is_instance_valid(other) and not processed.has(other) and not to_process.has(other):
				# Checa se estão muito próximos (chain_reaction_radius)
				if current.global_position.distance_to(other.global_position) <= chain_reaction_radius:
					if other.has_method("take_damage"):
						# Causa o dano normal da picareta, espalhando pela veia inteira!
						other.take_damage(Global.mining_power, multiplier, false)
						to_process.append(other)
						
						# Efeito visual da Corrente (Cria um rastro de sprites)
						if chain_sprite_base:
							var new_chain = chain_sprite_base.duplicate()
							var root = tree.current_scene
							if not root: root = tree.root
							root.add_child(new_chain)
							
							new_chain.show()
							
							# Coloca no meio entre a pedra atual e a próxima
							new_chain.global_position = current.global_position.lerp(other.global_position, 0.5)
							# Aponta a corrente na direção do percurso
							new_chain.rotation = current.global_position.direction_to(other.global_position).angle()
							
							# Dá um efeito de sumiço rápido
							var chain_tween = new_chain.create_tween()
							chain_tween.tween_property(new_chain, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_LINEAR)
							chain_tween.tween_callback(new_chain.queue_free)

var last_levelup_effect_time: float = 0.0

# --- EFEITO DE LEVEL UP ---
func play_level_up_effect() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_levelup_effect_time < 0.1:
		return # Previne overload de partículas se o auto-upgrade estiver comprando 60 levels por segundo
	last_levelup_effect_time = current_time
	
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.amount = 30
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 5.0
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.gravity = Vector2(0, -100) # Sobe igual fogos de artifício
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 60.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	
	# Arco-íris!
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 0, 0)) # Vermelho
	gradient.add_point(0.16, Color(1, 0.5, 0)) # Laranja
	gradient.add_point(0.33, Color(1, 1, 0)) # Amarelo
	gradient.add_point(0.5, Color(0, 1, 0)) # Verde
	gradient.add_point(0.66, Color(0, 0, 1)) # Azul
	gradient.add_point(0.83, Color(0.3, 0, 0.5)) # Indigo
	gradient.add_point(1.0, Color(0.5, 0, 1)) # Violeta
	
	particles.color_ramp = gradient
	
	add_child(particles)
	particles.emitting = true
	
	# Som de level up suave?
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = preload("res://powerUp (1).wav")
	if sfx.stream:
		sfx.bus = "SFX"
		sfx.pitch_scale = randf_range(1.0, 1.5)
		add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)
	
	var tw = create_tween()
	tw.tween_interval(1.5)
	tw.tween_callback(particles.queue_free)

# --- LOOP DE MINERAÇÃO ---
func _on_mining_timer_timeout() -> void:
	last_hit_time = Time.get_ticks_msec()
	
	# Restaura o tempo normal do timer caso tenha sido alterado pelo tempo restante (remaining)
	update_stats()
	
	# Mudamos de "interact" para "take_damage" para fazer sentido com os status
	if is_instance_valid(interact_target) and interact_target.has_method("take_damage"):
		
		# Guarda referência local porque take_damage da Porta/Loja pode anular o interact_target
		var target_node = interact_target
		
		var final_multiplier = Global.ore_multiplier
		if Global.current_mining_mode == MiningMode.AUTOMATIC and Global.is_afk_active:
			final_multiplier *= 0.5
		
		# Bate no alvo principal (ORIGINAL behavior)
		target_node.take_damage(Global.mining_power, final_multiplier, true)
		
		# Comportamento SHOCKWAVE
		if Global.current_mining_mode == MiningMode.SHOCKWAVE:
			var tree = get_tree()
			if tree:
				var ores = tree.get_nodes_in_group("ores")
				
				# Toca a animação do Shockwave
				if powers_anim and shockwave_sprite:
					shockwave_sprite.show()
					powers_anim.stop()
					powers_anim.play("ShockWave")
					# Opcional: Esconder no final da animação pode ser feito via Tween ou AnimationPlayer, 
					# mas vamos garantir que ele apague pelo script se a animação não o fizer:
					var hide_tween = create_tween()
					hide_tween.tween_interval(0.6) # Tempo da animação
					hide_tween.tween_callback(shockwave_sprite.hide)
				
				for ore in ores:
					# Evitar bater no alvo principal novamente e garantir que ele é válido
					if is_instance_valid(ore) and ore != target_node:
						if global_position.distance_to(ore.global_position) <= shockwave_radius:
							if ore.has_method("take_damage"):
								# Causamos dano no minério dentro do raio
								ore.take_damage(Global.mining_power, final_multiplier, false)
								
		# Comportamento CHAIN REACTION
		if Global.current_mining_mode == MiningMode.CHAIN_REACTION:
			var tree = get_tree()
			if tree and is_instance_valid(target_node):
				# Efeito do player até a primeira pedra
				if chain_sprite_base:
					var new_chain = chain_sprite_base.duplicate()
					var root = tree.current_scene
					if not root: root = tree.root
					root.add_child(new_chain)
					new_chain.show()
					new_chain.global_position = global_position.lerp(target_node.global_position, 0.5)
					new_chain.rotation = global_position.direction_to(target_node.global_position).angle()
					var chain_tween = new_chain.create_tween()
					chain_tween.tween_property(new_chain, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_LINEAR)
					chain_tween.tween_callback(new_chain.queue_free)
					
				_process_chain_reaction(target_node, final_multiplier)
		
		# Reinicia a animação para dar feedback visual do hit manual/automático
		if animated_player and current_state == State.MINING:
			animated_player.stop()
			
			# Sincroniza a velocidade da animação com o cooldown atual!
			if animated_player.has_animation("MINING"):
				var anim_length = animated_player.get_animation("MINING").length
				animated_player.speed_scale = anim_length / mining_timer.wait_time
			
			animated_player.play("MINING")
			
		# Reinicia o timer manualmente (já que agora é one_shot = true)
		if mining_timer:
			mining_timer.start()
	else:
		if mining_timer:
			mining_timer.stop()
		change_state(State.IDLE)

# --- GERENCIADOR DE ESTADOS E ANIMAÇÕES ---
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return # Evita reiniciar a animação se já estiver no estado correto
		
	current_state = new_state
	
	if current_state == State.IDLE:
		click_multiplier = 1.0
		multiplier_changed.emit(click_multiplier)
		update_stats()
	
	if animated_player:
		animated_player.speed_scale = 1.0 # Reseta a velocidade para outras animações
		match current_state:
			State.IDLE:
				animated_player.play("IDLE")
			State.MOVING, State.MOVING_TO_INTERACT:
				animated_player.play("WALK")
			State.MINING:
				# A velocidade é ajustada lá no timeout
				animated_player.play("MINING")
