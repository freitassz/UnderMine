extends CanvasLayer

@onready var money_label: Label = $MoneyLabel

var upgrades_ui_scene = preload("res://upgrades_ui.tscn")
var upgrades_ui: Control
var upgrades_btn: Button

func _ready() -> void:
	# Atualiza o texto logo que o jogo começa com o valor inicial
	_update_money_text(Global.money)
	
	# Conecta o sinal do Autoload para atualizar automaticamente sempre que ganhar dinheiro
	Global.money_changed.connect(_update_money_text)

	# Cria o botão de Melhorias
	upgrades_btn = Button.new()
	upgrades_btn.text = "Melhorias"
	upgrades_btn.position = Vector2(0, 30) # Abaixo do dinheiro
	add_child(upgrades_btn)
	
	# Instancia a interface de Melhorias
	upgrades_ui = upgrades_ui_scene.instantiate()
	add_child(upgrades_ui)
	
	upgrades_btn.pressed.connect(upgrades_ui.open)


# Função que formata e exibe o texto na tela
func _update_money_text(new_amount: int) -> void:
	money_label.text = "Moedas: " + str(new_amount)
