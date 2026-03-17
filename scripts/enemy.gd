class_name Enemy
extends CharacterBody2D

@export var speed: float = 40

var direction: int = 1


func _physics_process(delta: float) -> void:
	_set_velocity(delta)
	move_and_slide()
	_check_direction_change()


# Sets velocity and gravity
func _set_velocity(delta: float) -> void:
	if is_on_floor():
		velocity.x = direction * speed
	velocity += get_gravity() * delta


# Turn around if on a wall or an edge
func _check_direction_change() -> void:
	var wall_normal: Vector2 = Vector2.ZERO
	if is_on_wall():
		wall_normal = get_wall_normal()
	
	if not is_on_floor():
		return
	
	if wall_normal.x < 0 or not $RightCast.is_colliding():
		# Wall is to the right
		direction = -1
		$AnimatedSprite2D.flip_h = true
	elif wall_normal.x > 0 or not $LeftCast.is_colliding():
		# Wall is to the left
		direction = 1
		$AnimatedSprite2D.flip_h = false


func take_damage(_damage: int, knockback: Vector2) -> void:
	velocity = knockback
	if knockback.x > 0:
		direction = 1
		$AnimatedSprite2D.flip_h = false
	elif knockback.x < 0:
		direction = -1
		$AnimatedSprite2D.flip_h = true

func kill() -> void:
	queue_free()
