extends TileMapLayer

## Enum values are the atlas y-coordinates of these rows
enum TerrainColor {GREEN = 1, VIOLET = 2, TEAL = 3, PURPLE = 4}

## Sets all terrain blocks in this layer to [param color]
func set_terrain_color(color: TerrainColor):
	var used_cells := get_used_cells()
	for cell_coords in used_cells:
		if get_cell_tile_data(cell_coords).get_custom_data("Color-Changing"):
			_set_tile_color(cell_coords, color)

## Sets the tile at [param coords] to the new [param color]
func _set_tile_color(coords: Vector2i, color: TerrainColor):
	# Get current tile data
	var source_id = get_cell_source_id(coords)
	var atlas_coords = get_cell_atlas_coords(coords)
	var alternative_tile = get_cell_alternative_tile(coords)
	
	# Move atlas coords
	atlas_coords.y = color
	
	# Set new tile data
	set_cell(coords, source_id, atlas_coords, alternative_tile)

# Color Switcher For Debugging
var current_terrain_color: TerrainColor = TerrainColor.GREEN
func _input(event: InputEvent):
	if event.is_action_pressed("Debug"):
		var new_col = current_terrain_color + 1
		if new_col > TerrainColor.PURPLE: 
			new_col = 1
		set_terrain_color(new_col)
		current_terrain_color = new_col as TerrainColor
		print(TerrainColor.keys()[current_terrain_color-1], " ", new_col)
