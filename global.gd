extends Node

# Sinal para avisar a tela/UI sempre que o dinheiro mudar
signal money_changed(new_amount: int)
signal ore_selected(ore_name: String, max_hp: int, current_hp: int, lives: int)
signal ore_damaged(current_hp: int, lives: int)
signal ore_deselected()

var money: int = 10000
var floor_data_to_load: MineFloorData = null
var current_floor_index: int = 1

var has_stair_compass: bool = false
var has_ore_compass: bool = false
var has_mining_dash: bool = false
var has_midas_luck: bool = false
var has_shockwave: bool = false
var has_chain_reaction: bool = false
var has_automatic: bool = false
var has_alchemical: bool = false
var is_afk_active: bool = false

# --- PLAYER STATS (Moved to Global for persistence) ---
var mining_power: int = 1
var mining_speed_level: float = 1.0
var ore_multiplier: float = 1.0
var current_mining_mode: int = 0 # 0=ORIGINAL, 1=SHOCKWAVE, 2=CHAIN_REACTION, 3=AUTOMATIC, 4=ALCHEMICAL

var power_cost: int = 10
var speed_cost: int = 20
var mult_cost: int = 50

# Usar uma função ajuda a organizar e disparar o sinal automaticamente
func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)
	print("Dinheiro total na conta: ", money)
