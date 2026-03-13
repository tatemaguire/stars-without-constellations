extends CanvasLayer

@export var player_character: PlayerCharacter

func _ready() -> void:
	assert(player_character)
	player_character.player_damaged.connect(_set_healthbar)


func _set_healthbar(hp: int) -> void:
	for child in $Healthbar.get_children():
		if child is TextureRect:
			print(hp)
			# Get number next to "Heart" in the name
			var index = child.name.substr(5) as int
			child.visible = index <= hp
