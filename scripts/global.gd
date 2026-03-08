extends Node

const TILE_WIDTH: int = 8

@onready var viewport_size: Vector2i = get_viewport().get_visible_rect().size
@onready var screen_tile_size: Vector2 = viewport_size / float(TILE_WIDTH)
@onready var room_tile_size: Vector2i = ceil(screen_tile_size)
