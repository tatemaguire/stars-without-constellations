extends Camera2D

@export var _player_character: PlayerCharacter

@onready var _viewport: Vector2i = get_viewport().get_visible_rect().size

func _process(_delta) -> void:
	var p_pos: Vector2i = _player_character.position
	
	@warning_ignore("integer_division")
	position = (p_pos / _viewport) * _viewport
