## Basic room class for all rooms
class_name BasicRoom 
extends Node2D

@onready var terrain_layer: MulticolorTerrain = $Terrain

func set_door_states() -> void:
	pass

func set_terrain_color(color: MulticolorTerrain.TerrainColor) -> void:
	terrain_layer.set_terrain_color(color)
