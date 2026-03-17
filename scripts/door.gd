class_name Door
extends Node2D

@onready var closed_layer: TileMapLayer = $Closed
@onready var open_layer: TileMapLayer = $Open

func set_open(is_open: bool) -> void:
	open_layer.visible = is_open
	open_layer.collision_enabled = is_open
	closed_layer.visible = not is_open
	closed_layer.collision_enabled = not is_open

func set_terrain_color(color: MulticolorTerrain.TerrainColor) -> void:
	open_layer.set_terrain_color(color)
	closed_layer.set_terrain_color(color)
