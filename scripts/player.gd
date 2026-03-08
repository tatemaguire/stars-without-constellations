class_name PlayerCharacter extends CharacterBody2D

@export var max_speed: float = 100
@export var max_acceleration: float = 900
@export var drift: float = 900
@export var jump_velocity: float = 270


func _physics_process(delta: float) -> void:
	parse_inputs(delta)
	move_and_slide()


func parse_inputs(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Get horizontal input
	var direction = Input.get_axis("Left", "Right")
	
	# Flip Sprite based on direction
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false
	
	# Physics
	if direction != 0:
		# Calculate and apply acceleration
		var target_velocity = sign(direction) * max_speed
		var acceleration = abs(direction) * max_acceleration
		velocity.x = move_toward(velocity.x, target_velocity, acceleration * delta)
		# Play run anim
		$AnimatedSprite2D.play("run")
	else:
		# Apply drift
		velocity.x = move_toward(velocity.x, 0, drift * delta)
		$AnimatedSprite2D.play("idle")
	
	# Get jump input
	if is_on_floor() and Input.is_action_just_pressed("Jump"):
		velocity.y = -jump_velocity
