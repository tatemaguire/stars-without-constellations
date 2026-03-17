class_name MulticolorTerrain
extends TileMapLayer

## Enum values are the atlas y-coordinates of these rows
enum TerrainColor {GREEN = 1, VIOLET = 2, TEAL = 3, PURPLE = 4}

## Choose random terrain color (with optional range, inclusive)
static func random_terrain_color(_min: int = 1, _max: int = 4) -> TerrainColor:
	var index = randi_range(_min, _max)
	return index as TerrainColor

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
