extends Node

@onready var main_scene: PackedScene = preload("res://scenes/main.tscn")
@onready var end_screen: PackedScene = preload("res://scenes/ui/end_screen.tscn")

func load_main() -> void:
	get_tree().change_scene_to_packed(main_scene)

func _on_player_killed() -> void:
	get_tree().create_timer(1).timeout.connect(load_main)

func end_game() -> void:
	get_tree().change_scene_to_packed.call_deferred(end_screen)
