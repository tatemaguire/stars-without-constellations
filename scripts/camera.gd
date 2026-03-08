extends Camera2D

@export var _player_character: PlayerCharacter

func _process(_delta) -> void:
	var p_pos: Vector2i = _player_character.position
	
	@warning_ignore("integer_division")
	position = (p_pos / Global.viewport_size) * Global.viewport_size
