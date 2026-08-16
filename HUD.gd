extends CanvasLayer

@onready var money_label: Label = $MoneyLabel

func _ready() -> void:
	# Atualiza o texto logo que o jogo começa com o valor inicial
	_update_money_text(Global.money)
	
	# Conecta o sinal do Autoload para atualizar automaticamente sempre que ganhar dinheiro
	Global.money_changed.connect(_update_money_text)

# Função que formata e exibe o texto na tela
func _update_money_text(new_amount: int) -> void:
	money_label.text = "Moedas: " + str(new_amount)
