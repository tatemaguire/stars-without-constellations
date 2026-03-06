extends TileMapLayer
## THIS IS MY SCRIPT

class_name TerrainColorer

enum TerrainColor {GREEN, VIOLET, TEAL, PURPLE}

var current_terrain_color = TerrainColor.GREEN


func set_terrain_color(color: TerrainColor):
	
	print(color, " ", TerrainColor.size())
	current_terrain_color = color
	return null


func _input(event: InputEvent):
	if event.is_action_pressed("Jump"):
		set_terrain_color(current_terrain_color+1)
