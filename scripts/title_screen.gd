extends Control

@onready var main_scene: PackedScene = preload("res://scenes/main.tscn")

func _on_button_click() -> void:
	get_tree().change_scene_to_packed(main_scene)
