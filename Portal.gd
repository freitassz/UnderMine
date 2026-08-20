extends Interactable
class_name Portal

@export var portal_floor_data: MineFloorData # A data deste portal
@export var mine_scene_path: String = "res://Data/Resource/Levels/mine_scene.tscn"

func _ready() -> void:
	super._ready() # Conecta o clique do Interactable

# O player clica no portal, anda até ele e tenta "bater". 
# Quando isso acontece, ele é teletransportado!
func take_damage(_power: int, _mult: float, _is_main_target: bool = true) -> void:
	# Passa a data do portal para o Autoload e zera os andares
	Global.floor_data_to_load = portal_floor_data
	Global.current_floor_index = 1
	
	# Salva o jogo ao entrar na mina
	SaveManager.save_game()
	
	# Muda para a cena da mina
	get_tree().change_scene_to_file(mine_scene_path)
