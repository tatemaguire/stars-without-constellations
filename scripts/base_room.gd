## Basic room class for all rooms
class_name BasicRoom 
extends Node2D

@onready var terrain_layer: MulticolorTerrain = $Terrain
@onready var left_door: Door = $Doors/LeftDoor
@onready var right_door: Door = $Doors/RightDoor
@onready var top_door: Door = $Doors/TopDoor
@onready var bottom_door: Door = $Doors/BottomDoor

func set_door_states(left: bool, right: bool, top: bool, bottom: bool) -> void:
	left_door.set_open(left)
	right_door.set_open(right)
	top_door.set_open(top)
	bottom_door.set_open(bottom)

func set_terrain_color(color: MulticolorTerrain.TerrainColor) -> void:
	terrain_layer.set_terrain_color(color)
	left_door.set_terrain_color(color)
	right_door.set_terrain_color(color)
	top_door.set_terrain_color(color)
	bottom_door.set_terrain_color(color)
