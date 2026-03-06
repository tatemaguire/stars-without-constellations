extends TileMapLayer

enum TerrainColor {GREEN, VIOLET, TEAL, PURPLE}

@export var current_terrain_color: TerrainColor = TerrainColor.GREEN

func set_terrain_color(color: TerrainColor):
	current_terrain_color = color

func _input(event: InputEvent):
	if event.is_action_pressed("Jump"):
		var new_col = current_terrain_color + 1
		new_col %= TerrainColor.size()
		print(new_col)
		set_terrain_color(new_col)
