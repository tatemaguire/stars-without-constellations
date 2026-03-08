@tool
extends Node2D

@export_category("File References")
## Directory containing all basic room scenes
@export_dir var room_directory: String
## Entrance scene reference
@export var entrance_scene: PackedScene
## Backyard scene reference
@export var backyard_scene: PackedScene

@export_category("Map Generation")
## Generate map in-editor for debugging
@export_tool_button("Generate Map") var generate_map_action = generate_map
## Clear map in-editor for debugging
@export_tool_button("Clear Map") var clear_map_action = clear_map
## Maximum room size of the map
@export var map_size := Vector2i(5, 5)
## Length of main_path from entrance to backyard
@export var main_path_length: int = 8
## Number of branches
@export var num_branches: int = 2

## Scene references
var _basic_room_scenes: Array[PackedScene]

@onready var room_size: Vector2 = ProjectSettings.get_setting("global/room_size")


func _ready() -> void:
	# Load _basic_room_scenes
	var room_files = ResourceLoader.list_directory(room_directory)
	for file in room_files:
		var room_scene: PackedScene = load(room_directory + "/" + file)
		_basic_room_scenes.append(room_scene)
	
	# Initial generation
	generate_map()


func generate_map() -> void:
	clear_map()
	var entrance: Node2D = entrance_scene.instantiate()
	add_child(entrance)
	
	for i in range(_basic_room_scenes.size()):
		var room = _basic_room_scenes[i].instantiate()
		room.position.x += room_size.x * (i + 1)
		add_child(room)

func clear_map() -> void:
	for room in get_children():
		room.free()
