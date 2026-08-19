extends CharacterBody2D

# --- VARIÁVEIS DE ESTADO E NAVEGAÇÃO ---
enum State { IDLE, MOVING, MOVING_TO_INTERACT, MINING, LEAPING }
var current_state: State = State.IDLE

signal multiplier_changed(mult: float)


# --- STATUS DE MINERAÇÃO (UPGRADES) ---
var mining_power: int = 1         # Dano causado à pedra por cada batida
var mining_speed_level: float = 1.0 # Nível de velocidade (usado na fórmula do Timer)
var ore_multiplier: float = 1.0   # Multiplicador do dinheiro final (Ex: 1.0, 1.2, 2.5)

const BASE_MINE_TIME: float = 1.0 # Tempo base (1 segundo por batida)
const MIN_MINE_TIME: float = 0.1  # Limite máximo de velocidade (10 batidas por segundo)

@export var speed: float = 200.0
@export var interact_distance: float = 60.0 # Distância para parar antes de bater

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var mining_timer: Timer = $MiningTimer 

@export var animated_player: AnimationPlayer

# Alterado de Area2D para Node2D para ser mais genérico na hora de receber o alvo
var interact_target: Node2D = null

var last_hit_time: int = 0
var click_multiplier: float = 1.0
const MAX_CLICK_MULTIPLIER: float = 1.5
const CLICK_MULTIPLIER_STEP: float = 0.01

func _ready() -> void:
	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 10.0
	
	if mining_timer:
		mining_timer.one_shot = false
		update_stats() # <-- Substitui a definição manual de wait_time
		mining_timer.timeout.connect(_on_mining_timer_timeout)
		
	change_state(State.IDLE)



func update_stats() -> void:
	# Fórmula: Tempo Base dividido pelo Nível de Velocidade e pelo multiplicador de clique manual
	var new_wait_time = (BASE_MINE_TIME / mining_speed_level) / click_multiplier
	
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
		
		# Se o clique acertou qualquer Area2D, paramos o código por aqui e deixamos
		# a função _on_input_event da pedra assumir o controle!
		if results.size() > 0:
			return
			
		# Se chegou aqui embaixo, significa que bateu no chão livre de verdade
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
		
	# CHECAGEM DE ONE-HIT DASH
	var will_destroy = false
	if "current_hp" in target_node and "current_lives" in target_node:
		var total_health = target_node.current_hp
		if "my_data" in target_node and target_node.my_data != null:
			total_health += (target_node.current_lives * target_node.my_data.max_hp)
			
		if mining_power >= total_health:
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

# --- LOOP DE MINERAÇÃO ---
func _on_mining_timer_timeout() -> void:
	last_hit_time = Time.get_ticks_msec()
	
	# Restaura o tempo normal do timer caso tenha sido alterado pelo tempo restante (remaining)
	update_stats()
	
	# Mudamos de "interact" para "take_damage" para fazer sentido com os status
	if is_instance_valid(interact_target) and interact_target.has_method("take_damage"):
		# Passamos o dano (poder) e o multiplicador de moedas para o minério
		interact_target.take_damage(mining_power, ore_multiplier)
		
		# Reinicia a animação para dar feedback visual do hit manual/automático
		if animated_player and current_state == State.MINING:
			animated_player.stop()
			animated_player.play("MINING")
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
		match current_state:
			State.IDLE:
				animated_player.play("IDLE")
			State.MOVING, State.MOVING_TO_INTERACT:
				animated_player.play("WALK")
			State.MINING:
				animated_player.play("MINING")
