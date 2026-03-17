extends Control

@onready var main_scene: PackedScene = preload("res://scenes/main.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Start Game"):
		SceneTransitions.load_main()
