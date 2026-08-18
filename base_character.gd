extends CharacterBody2D

# --- VARIÁVEIS DE ESTADO E NAVEGAÇÃO ---
enum State { IDLE, MOVING, MOVING_TO_INTERACT, MINING }
var current_state: State = State.IDLE

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

func _ready() -> void:
	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 10.0
	
	if mining_timer:
		mining_timer.one_shot = false
		update_stats() # <-- Substitui a definição manual de wait_time
		mining_timer.timeout.connect(_on_mining_timer_timeout)
		
	change_state(State.IDLE)



func update_stats() -> void:
	# Fórmula: Tempo Base dividido pelo Nível de Velocidade
	# Se o level for 1, bate a cada 1s. Se for 2, bate a cada 0.5s. Se for 4, bate a cada 0.25s.
	var new_wait_time = BASE_MINE_TIME / mining_speed_level
	
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
	interact_target = null
	change_state(State.MOVING)
	nav_agent.target_position = target_point
	nav_agent.target_desired_distance = 2.0 
	if mining_timer and !mining_timer.is_stopped():
		mining_timer.stop()

func walk_to_interact(target_node: Node2D) -> void: 
	interact_target = target_node
	
	# <-- Pede para o minério enviar as informações dele para a tela
	if is_instance_valid(target_node) and target_node.has_method("select_ore"):
		target_node.select_ore()
		
	change_state(State.MOVING_TO_INTERACT)
	nav_agent.target_position = target_node.global_position
	nav_agent.target_desired_distance = interact_distance 
	if mining_timer and !mining_timer.is_stopped():
		mining_timer.stop()

# --- MÁQUINA DE ESTADOS E MOVIMENTAÇÃO ---
func _physics_process(_delta: float) -> void:
	match current_state:
		State.IDLE, State.MINING:
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
						_on_mining_timer_timeout() # Aplica o primeiro dano imediatamente
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
	# Mudamos de "interact" para "take_damage" para fazer sentido com os status
	if is_instance_valid(interact_target) and interact_target.has_method("take_damage"):
		# Passamos o dano (poder) e o multiplicador de moedas para o minério
		interact_target.take_damage(mining_power, ore_multiplier)
	else:
		mining_timer.stop()
		change_state(State.IDLE)

# --- GERENCIADOR DE ESTADOS E ANIMAÇÕES ---
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return # Evita reiniciar a animação se já estiver no estado correto
		
	current_state = new_state
	
	if animated_player:
		match current_state:
			State.IDLE:
				animated_player.play("IDLE")
			State.MOVING, State.MOVING_TO_INTERACT:
				animated_player.play("WALK")
			State.MINING:
				animated_player.play("MINING")
