extends Camera2D

@export var _player_character: PlayerCharacter

@onready var _room_size: Vector2i = ProjectSettings.get_setting("global/room_size")

func _process(_delta) -> void:
	var p_screen_pos: Vector2i = Vector2i(_player_character.position - position)
	
	# Check if camera needs to move in the x-direction
	if p_screen_pos.x < 0:
		position.x -= _room_size.x
	elif p_screen_pos.x > _room_size.x:
		position.x += _room_size.x
	
	# Check if camera needs to move in the y-direction
	if p_screen_pos.y < 0:
		position.y -= _room_size.y
	elif p_screen_pos.y > _room_size.y:
		position.y += _room_size.y
