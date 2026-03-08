@tool
extends EditorScript

func _run() -> void:
	update_global_constants()

func update_global_constants() -> void:
	var TILE_WIDTH = ProjectSettings.get_setting("global/TILE_WIDTH")
	
	var viewport_w = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_h = ProjectSettings.get_setting("display/window/size/viewport_height")
	
	var viewport_size := Vector2i(viewport_w, viewport_h)
	var viewport_size_T: Vector2 = viewport_size / float(TILE_WIDTH)
	var room_size_T: Vector2i = ceil(viewport_size_T)
	var room_size: Vector2i = room_size_T * TILE_WIDTH
	
	ProjectSettings.set_setting("global/viewport_size", viewport_size)
	ProjectSettings.set_setting("global/viewport_size_T", viewport_size_T)
	ProjectSettings.set_setting("global/room_size_T", room_size_T)
	ProjectSettings.set_setting("global/room_size", room_size)
