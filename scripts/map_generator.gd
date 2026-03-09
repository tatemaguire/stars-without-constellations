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

@export_category("Map Generation")
## Generate map in-editor for debugging
@export_tool_button("Generate Map") var generate_map_action = generate_map
## Clear map in-editor for debugging
@export_tool_button("Clear Map") var clear_map_action = clear_map
## Regenerate the map when starting the game (happens in _ready)
@export var generate_on_ready: bool = true
## Maximum room size of the map
@export var map_size := Vector2i(5, 5)
## Length of main_path from entrance to backyard
@export var main_path_length: int = 8
## Number of branches
@export var num_branches: int = 2
## Length of branches
@export var branch_length: int = 4

## Scene references
var _basic_room_scenes: Array[PackedScene]
## Current room coordinate of the pathway being generated
var _current_room: Vector2i
## Grid of rooms on the map
var _map_grid: Array[Array]

## room_size in pixels
@onready var room_size: Vector2i = ProjectSettings.get_setting("global/room_size")

func _ready() -> void:
	
	_load_room_scenes()
	
	if generate_on_ready:
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
	
	# ---------- Generate Map Grid -----------
	var start_y: int
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
		start_y = randi_range(0, map_size.y-1)
		_map_grid[0][start_y] = main_path_length
		_current_room = Vector2i(0, start_y)
		
		# Generate main path in _map_grid
		if _create_path(main_path_length - 1):
			successful = true
			break
	
	if not successful:
		printerr("Can't generate main path of map")
		return
	
	_print_grid()
	
	# ---------- Fill The Scene With Rooms -----------
	
	clear_map()
	_fill_map_from_grid(start_y)
	
	# Set basic roms to be violet
	for room in get_children():
		if room is BasicRoom:
			room.set_terrain_color(MulticolorTerrain.random_terrain_color(2, 4))


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
		# Check that it's in the bounds of map_size
		if (new_room.x < 0 
				or new_room.x >= map_size.x 
				or new_room.y < 0 
				or new_room.y >= map_size.y):
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


func _fill_map_from_grid(start_y: int) -> void:
	# Fill main portion of map
	for i in range(map_size.x):
		for j in range(map_size.y):
			var room: Node2D
			if _map_grid[i][j] == 0:
				room = filler_scene.instantiate()
			else:
				var random_index := randi_range(0, _basic_room_scenes.size() - 1)
				room = _basic_room_scenes[random_index].instantiate()
			# Set room position
			room.position = Vector2i(i, j) * room_size
			add_child(room)
	
	# Fill side edges of map including entrance and backyard
	for j in range(map_size.y):
		# Left edge of the map
		var room: Node2D
		if j == start_y:
			room = entrance_scene.instantiate()
		else:
			room = filler_scene.instantiate()
		room.position = Vector2i(-1, j) * room_size
		add_child(room)
		
		# Right edge of the map
		room = null
		if j == _current_room.y:
			room = backyard_scene.instantiate()
		else:
			room = filler_scene.instantiate()
		room.position = Vector2i(map_size.x, j) * room_size
		add_child(room)
		
	# Fill top and bottom edges
	for i in range(map_size.x):
		# Top edge
		var room: Node2D = filler_scene.instantiate()
		room.position = Vector2i(i, -1) * room_size
		add_child(room)
		
		# Bottom edge
		room = filler_scene.instantiate()
		room.position = Vector2i(i, map_size.y) * room_size
		add_child(room)


# Prints _map_grid
func _print_grid() -> void:
	print("")
	for j in range(map_size.x):
		var row = ""
		for i in range(map_size.y):
			row += str(_map_grid[i][j]) + " "
		print(row)
