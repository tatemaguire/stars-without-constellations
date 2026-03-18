class_name ItemPickup
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

@export var item_data: Item

func _ready() -> void:
	sprite.texture = item_data.icon

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		var successful = body.pickup_item(item_data)
		if successful:
			destroy()

func destroy() -> void:
	queue_free()
