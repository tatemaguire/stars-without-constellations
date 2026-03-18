@tool
extends Node2D

@export_category("File References")
## Directory containing all basic room scenes
@export_dir var room_directory: String
## Entrance scene reference
@export var entrance_scene: PackedScene
## Backyard scene reference
@export var backyard_scene: PackedScene
## Filler scene reference
@export var filler_scene: PackedScene
## Item Pickup scene reference
@export var item_pickup_scene: PackedScene

@export_category("Map Generation")
## Generate map in-editor for debugging
@export_tool_button("Generate Map") var generate_map_action = generate_map
## Clear map in-editor for debugging
@export_tool_button("Clear Map") var clear_map_action = clear_map
## Maximum room size of the map
@export var map_size := Vector2i(5, 5)
## Length of main_path from entrance to backyard
@export var main_path_length: int = 8
### Number of branches
#@export var num_branches: int = 2
### Length of branches
#@export var branch_length: int = 4

@export_category("Item Generation")
## Array of items
@export var items: Array[Item]

## Scene references
var _basic_room_scenes: Array[PackedScene]
## Current room coordinate of the pathway being generated
var _current_room: Vector2i
## Grid of rooms on the map
var _map_grid: Array[Array]
## Current entrance room coordinate
var entrance_coord: Vector2i
## Current backyard room coordinate
var backyard_coord: Vector2i

## room_size in pixels
@onready var room_size: Vector2i = ProjectSettings.get_setting("global/room_size")

func _ready() -> void:
	
	_load_room_scenes()
	generate_map()
	
	if not Engine.is_editor_hint():
		# TODO: Clean up these references
		# Move player to spawn point
		var player_spawn: Node2D = get_node("Entrance/PlayerSpawn")
		assert(player_spawn)
		var player: PlayerCharacter = get_parent().get_node("Player")
		player.global_position = player_spawn.global_position
	
	

## Generates the entire map, with entrance, backyard, main path, and branches
## Fills the map with exported scene references
func generate_map() -> void:
	assert(main_path_length >= map_size.x)
	
	entrance_coord = Vector2i(-1, 0)
	backyard_coord = Vector2i(map_size.x, 0)
	
	# ---------- Generate Map Grid -----------
	var successful: bool = false
	# Try 10 times
	for attempt in range(10):
	
		# Initialize map_grid with zeros
		_map_grid.clear()
		for i in map_size.x:
			_map_grid.append([])
			for j in map_size.y:
				_map_grid[i].append(0)
		
		# Choose starting room randomly
		entrance_coord.y = randi_range(0, map_size.y-1)
		_map_grid[0][entrance_coord.y] = main_path_length
		_current_room = entrance_coord + Vector2i.RIGHT
		
		# Generate main path in _map_grid
		if _create_path(main_path_length - 1):
			successful = true
			break
	
	if not successful:
		printerr("Can't generate main path of map")
		return
	
	backyard_coord = _current_room + Vector2i.RIGHT
	
	_print_grid()
	
	# ---------- Fill The Scene With Rooms -----------
	
	clear_map()
	_fill_map_from_grid()
	_fill_map_with_items()
	
	# Set basic rooms to be different colors
	if not Engine.is_editor_hint():
		var world_terrain_color = MulticolorTerrain.random_terrain_color()
		for room in get_children():
			if room is BasicRoom:
				room.set_terrain_color(world_terrain_color)


## Frees all children of the map node
func clear_map() -> void:
	for room in get_children():
		room.free()


# Loads packed scene resources from file directory into _basic_room_scenes
func _load_room_scenes() -> void:
	var room_files = ResourceLoader.list_directory(room_directory)
	for file in room_files:
		var room_scene: PackedScene = load(room_directory + "/" + file)
		_basic_room_scenes.append(room_scene)


# Recursively generates a path of length_remaining
# Starting at _current_room within _map_grid
# Returns true if valid path is found
func _create_path(length_remaining: int) -> bool:
	if length_remaining == 0:
		# Return true if we are at the right edge of the map
		return _current_room.x == map_size.x - 1
	
	# Start with a random direction
	var direction_index: int = randi_range(0, 3)
	var direction: Vector2i
	for i in range(4):
		# Cycle through four directions
		direction_index += i
		direction_index %= 4
		match direction_index:
			0:
				direction = Vector2i.UP
			1:
				direction = Vector2i.LEFT
			2:
				direction = Vector2i.DOWN
			3:
				direction = Vector2i.RIGHT
		
		# Apply direction to the current room
		var new_room: Vector2i = _current_room + direction
		# Check bounds
		if not _in_map_bounds(new_room):
			continue
		# See if this new room is empty
		if int(_map_grid[new_room.x][new_room.y]) == 0:
			# Fill this room
			_map_grid[new_room.x][new_room.y] = length_remaining
			
			var old_room := _current_room
			_current_room = new_room
			# Check if this current room is valid by recursive generation
			var is_valid: bool = _create_path(length_remaining - 1)
			if is_valid:
				return true
			else:
				# Revert
				_map_grid[new_room.x][new_room.y] = 0
				_current_room = old_room
				continue
	
	# If no valid path is found, return false; this current_room is invalid
	return false


func _fill_map_from_grid() -> void:
	# Fill main portion of map
	for i in range(map_size.x):
		for j in range(map_size.y):
			if _map_grid[i][j] != 0:
				# Instantiate random basic room
				var random_index := randi_range(0, _basic_room_scenes.size() - 1)
				var room: BasicRoom = _basic_room_scenes[random_index].instantiate()
				# Set room position
				room.position = Vector2i(i, j) * room_size
				add_child(room)
				_set_door_states_using_grid(room, Vector2i(i, j))
	
	# Create Entrance
	var entrance_room: Node2D = entrance_scene.instantiate()
	entrance_room.position = entrance_coord * room_size
	add_child(entrance_room)
	# Create Backyard
	var backyard_room: Node2D = backyard_scene.instantiate()
	backyard_room.position = backyard_coord * room_size
	add_child(backyard_room)


## Randomly place all items at the ItemSpawn locations
func _fill_map_with_items() -> void:
	if Engine.is_editor_hint():
		return
		
	# Fill item_spawns with all ItemSpawn markers throughout the world
	var item_spawns: Array[Marker2D]
	for room in get_children():
		if room is BasicRoom:
			for child in room.get_children():
				if "ItemSpawn" in child.name:
					item_spawns.append(child)
	
	# Place all items in random locations
	for item in items:
		# Instantiate the pickup
		var item_pickup: ItemPickup = item_pickup_scene.instantiate()
		item_pickup.item_data = item
		add_child(item_pickup)
		# Choose random item spawn location
		var i := randi_range(0, item_spawns.size()-1)
		var spawn: Marker2D = item_spawns.pop_at(i)
		item_pickup.global_position = spawn.global_position



func _set_door_states_using_grid(room: BasicRoom, room_pos: Vector2i) -> void:
	var adj_is_room: Dictionary = {
		Vector2i.LEFT: false,
		Vector2i.RIGHT: false,
		Vector2i.UP: false,
		Vector2i.DOWN: false,
	}
	# Figure out what adjacent cells have rooms
	for dir in adj_is_room:
		var adj_cell: Vector2i = room_pos + dir
		if _in_map_bounds(adj_cell) and _map_grid[adj_cell.x][adj_cell.y] != 0:
			adj_is_room[dir] = true
		# Check if it's the entrance or backyard
		if adj_cell == entrance_coord or adj_cell == backyard_coord:
			adj_is_room[dir] = true
	# Set door states
	if not Engine.is_editor_hint():
		room.set_door_states(adj_is_room[Vector2i.LEFT], adj_is_room[Vector2i.RIGHT],
				adj_is_room[Vector2i.UP], adj_is_room[Vector2i.DOWN])
	

# Check if coordinate in map bounds
func _in_map_bounds(coord: Vector2i) -> bool:
	var bounds: Rect2i = Rect2i(Vector2i.ZERO, map_size)
	return bounds.has_point(coord)
		

# Prints _map_grid
func _print_grid() -> void:
	print("")
	for j in range(map_size.y):
		var row = ""
		for i in range(map_size.x):
			row += str(_map_grid[i][j]) + " "
		print(row)
