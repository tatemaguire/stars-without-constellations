extends Node

## Width of one tile
const TILE_WIDTH: int = 8

## Pixel dimensions of the viewport
@onready var viewport_size: Vector2i = get_viewport().get_visible_rect().size
## Tile dimensions of the viewport
@onready var viewport_size_T: Vector2 = viewport_size / float(TILE_WIDTH)
## Tile dimensions of a room
@onready var room_size_T: Vector2i = ceil(viewport_size_T)
## Pixel dimensions of a room
@onready var room_size: Vector2i = room_size_T * TILE_WIDTH
