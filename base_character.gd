extends CharacterBody2D

# --- VARIÁVEIS DE ESTADO E NAVEGAÇÃO ---
enum State { IDLE, MOVING, MOVING_TO_INTERACT, MINING }
var current_state: State = State.IDLE

@export var speed: float = 200.0
@export var interact_distance: float = 60.0 # Distância para parar antes de bater

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var mining_timer: Timer = $MiningTimer 

var interact_target: Area2D = null

func _ready() -> void:
	# Evita que o personagem fique tremendo ao chegar no destino
	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 10.0
	
	# Configura o Timer de mineração via código
	if mining_timer:
		mining_timer.one_shot = false
		mining_timer.wait_time = 0.5 # Dá dano a cada 0.5 segundos
		mining_timer.timeout.connect(_on_mining_timer_timeout)

# --- DETECÇÃO DE CLIQUES NO CHÃO ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Se clicou no chão livre, anda até o ponto
		walk_to_point(get_global_mouse_position())

# --- FUNÇÕES DE DEFINIÇÃO DE ALVO ---
func walk_to_point(target_point: Vector2) -> void:
	interact_target = null
	current_state = State.MOVING
	nav_agent.target_position = target_point
	
	# Tolerância quase zero: obriga o personagem a ir EXATAMENTE onde você clicou
	nav_agent.target_desired_distance = 2.0 
	
	if mining_timer and !mining_timer.is_stopped():
		mining_timer.stop()

func walk_to_interact(target_node: Node2D) -> void: 
	interact_target = target_node
	current_state = State.MOVING_TO_INTERACT
	nav_agent.target_position = target_node.global_position
	
	# Tolerância maior: faz ele parar assim que chegar na distância de bater na pedra
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
				current_state = State.IDLE
				velocity = Vector2.ZERO
				return
			_process_movement()
			
		State.MOVING_TO_INTERACT:
			# Verifica se o minério ainda existe (pode ter sido quebrado sem respawn)[cite: 1]
			if is_instance_valid(interact_target):
				var distance = global_position.distance_to(interact_target.global_position)
				
				# Se chegou perto o suficiente, para e começa a minerar[cite: 1]
				if distance <= interact_distance:
					current_state = State.MINING
					velocity = Vector2.ZERO
					if mining_timer:
						mining_timer.start()
						_on_mining_timer_timeout() # Aplica o primeiro dano imediatamente
					return
				else:
					# Continua andando até a pedra
					_process_movement()
			else:
				# O minério foi destruído usando queue_free() antes do jogador chegar[cite: 1]
				current_state = State.IDLE
				velocity = Vector2.ZERO

func _process_movement() -> void:
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * speed
	
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
	# Checa se o alvo existe e se possui o método de interação
	if is_instance_valid(interact_target) and interact_target.has_method("interact"):
		interact_target.interact()
	else:
		# Se a pedra foi destruída permanentemente, o jogador volta ao estado IDLE[cite: 1]
		mining_timer.stop()
		current_state = State.IDLE
