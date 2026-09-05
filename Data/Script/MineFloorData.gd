class_name MineFloorData extends Resource

@export var floor_name: String = "Mina Inicial"
@export var total_floors: int = 5 # Quantidade total de andares dessa fase
@export var ore_set: OreSetData # Aqui você arrasta o Conjunto criado acima
@export_range(0.0, 100.0) var spread: float = 40.0 # 100 = Muito colado (denso), 0 = Bem espaçado
