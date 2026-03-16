extends CharacterBody2D

@export var speed: float = 40
@export var damage: int = 1
@export var knockback_velocity: float = 200

var direction: int = 1

func _physics_process(delta: float) -> void:
	_set_velocity(delta)
	move_and_slide()
	_process_collisions()


func _set_velocity(delta: float) -> void:
	velocity.x = direction * speed
	velocity += get_gravity() * delta


func _process_collisions() -> void:
	# Turn around if on a wall
	if is_on_wall():
		var wall_normal = get_wall_normal()
		if wall_normal.x < 0: # Wall is to the right
			direction = -1
			$AnimatedSprite2D.flip_h = true
		else: # Wall is to the left
			direction = 1
			$AnimatedSprite2D.flip_h = false
	
	# Process collision with player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is PlayerCharacter:
			# calculate knockback velocity
			var knockback: Vector2 = (collider.global_position - self.global_position).normalized()
			knockback = knockback.normalized() * knockback_velocity
			# apply damage and knockback
			collider.take_damage(damage, knockback)
		
		
