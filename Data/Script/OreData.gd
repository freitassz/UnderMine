class_name OreData extends Resource

@export var name: String # A imagem/Sprite2D do minério
@export var texture: Texture2D # A imagem/Sprite2D do minério
@export var money_drop: int = 10 # Dinheiro ganho ao quebrar uma vida
@export var max_hp: int = 3 # Quantas porradas para perder uma vida
@export var extra_lives: int = 0 # Quantas vezes ele ressurge no mesmo lugar antes de sumir permanentemente
