extends Interactable
class_name Portal

@export var portal_floor_data: MineFloorData # A data deste portal
@export var mine_scene_path: String = "res://Data/Resource/Levels/mine_scene.tscn"

func _ready() -> void:
	pass

# Supondo que você use o sinal "body_entered" do Area2D para detectar o jogador
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): # Verifica se quem entrou foi o jogador
		# Passa a data do portal para o Autoload
		Global.floor_data_to_load = portal_floor_data
		
		# Muda para a cena da mina
		get_tree().change_scene_to_file(mine_scene_path)
