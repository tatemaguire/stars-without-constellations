## Basic room class for all rooms
class_name Room 
extends Node2D

@onready var terrain_layer: TileMapLayer = $Terrain

func _init() -> void:
	_set_terrain_color("GREEN")

func _set_door_states() -> void:
	pass

func _set_terrain_color(color) -> void:
	print("set to: ", color)
