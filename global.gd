extends Node

# Sinal para avisar a tela/UI sempre que o dinheiro mudar
signal money_changed(new_amount: int)
signal ore_selected(ore_name: String, max_hp: int, current_hp: int, lives: int)
signal ore_damaged(current_hp: int, lives: int)
signal ore_deselected()

var money: int = 0
var floor_data_to_load: MineFloorData = null

# Usar uma função ajuda a organizar e disparar o sinal automaticamente
func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)
	print("Dinheiro total na conta: ", money)
