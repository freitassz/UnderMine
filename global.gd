extends Node

# Sinal para avisar a tela/UI sempre que o dinheiro mudar
signal money_changed(new_amount: int)

var money: int = 0

# Usar uma função ajuda a organizar e disparar o sinal automaticamente
func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)
	print("Dinheiro total na conta: ", money)
