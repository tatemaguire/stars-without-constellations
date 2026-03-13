class_name PlayerCharacter extends CharacterBody2D

enum States {GROUND, JUMPING, FALLING, COYOTE, DEAD}

## Max player speed 
@export var max_speed: float = 70
## Forward acceleration
@export var acceleration: float = 600
## Acceleration when slowing down
@export var damping: float = 900
## Acceleration due to gravity
@export var gravity: float = 600
## Velocity of jump, applied upwards
@export var jump_velocity: float = 180
## Acceleration downwards if jump ends early
@export var jump_suppression_acceleration: float = 70
## Time in s of coyote effect (jumping after running off edge)
@export var coyote_time: float = 0.08
## Time in s of invinsibility after taking damage
@export var invincibility_time: float = 0.8

# State Variables
# The following variables describe the player's state
var current_state: States = States.FALLING
var remaining_coyote_time: float = 0
var direction: float = 0
var suppress_jump: bool = false
var hp: int = 4
var invincible: bool = false
var remaining_invincibility_time: float = 0

signal player_damaged(current_health: int)
signal player_killed

func _physics_process(delta: float) -> void:
	_update_invincibility(delta)
	_process_state(delta)
	_check_state_transitions()
	move_and_slide()


# Applying the state per-frame
func _process_state(delta: float) -> void:
	match current_state:
		States.GROUND:
			_parse_input(delta)
			_apply_damping(delta)
			if direction != 0:
				$AnimatedSprite2D.play("run")
			else:
				$AnimatedSprite2D.play("idle")
		States.JUMPING:
			_parse_input(delta)
			_apply_gravity(delta)
			_apply_damping(delta)
			# Jump Suppression
			if not suppress_jump and not Input.is_action_pressed("Jump"):
				suppress_jump = true
			if suppress_jump:
				velocity.y += jump_suppression_acceleration
		States.FALLING:
			_parse_input(delta)
			_apply_gravity(delta)
			_apply_damping(delta)
		States.COYOTE:
			_parse_input(delta)
			_apply_gravity(delta)
			_apply_damping(delta)
			remaining_coyote_time -= delta
		States.DEAD:
			_apply_gravity(delta)
			_apply_damping(delta)


# For each state, check the conditions for transitioning
# Important that only one of these is called per frame (if elif elif else)
func _check_state_transitions():
	# Check if dead
	if hp <= 0:
		_transition_state(States.DEAD)
		return
	
	match current_state:
		States.GROUND:
			if Input.is_action_just_pressed("Jump"):
				_transition_state(States.JUMPING)
			elif not is_on_floor():
				_transition_state(States.COYOTE)
		States.JUMPING:
			if is_on_floor():
				_transition_state(States.GROUND)
			elif velocity.y > 0:
				# TODO: what's a better way to do this? cancels jump suppression
				velocity.y = 0
				_transition_state(States.FALLING)
		States.FALLING:
			if is_on_floor():
				if Input.is_action_pressed("Jump"):
					_transition_state(States.JUMPING)
				else:
					_transition_state(States.GROUND)
		States.COYOTE:
			if Input.is_action_just_pressed("Jump"):
				_transition_state(States.JUMPING)
			elif is_on_floor():
				_transition_state(States.GROUND)
			elif remaining_coyote_time < 0:
				_transition_state(States.FALLING)


# On transitioning to a new_state
func _transition_state(new_state: States) -> void:
	# On entering new_state
	match new_state:
		States.JUMPING:
			if Input.is_action_pressed("Down"):
				_jump_down()
			else:
				velocity.y = -jump_velocity
				suppress_jump = false
		States.COYOTE:
			remaining_coyote_time = coyote_time
		States.DEAD:
			kill()
	
	current_state = new_state


# Function that's called during many states where player has control
# updates the direction variable
func _parse_input(delta: float) -> void:
	direction = Input.get_axis("Left", "Right")
	
	# Sprite orientation
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false

	# Horizontal movement
	if direction != 0:
		var target_velocity = sign(direction) * max_speed
		var accel = abs(direction) * acceleration
		velocity.x = move_toward(velocity.x, target_velocity, accel * delta)


func _apply_gravity(delta: float) -> void:
	velocity.y += gravity * delta


func _apply_damping(delta: float) -> void:
	if absf(direction) < 1e-4:
		velocity.x = move_toward(velocity.x, 0, damping * delta)


func _jump_down() -> void:
	position.y += 1


func _update_invincibility(delta: float) -> void:
	if not invincible:
		return
	
	remaining_invincibility_time -= delta
	if remaining_invincibility_time < 0:
		invincible = false


func take_damage(damage: int, knockback: Vector2) -> void:
	if invincible:
		return
	
	hp -= damage
	player_damaged.emit(hp)
	print("DAMAGED: ", hp)
	
	# Knockback
	velocity += knockback
	
	# Invincibility
	invincible = true
	remaining_invincibility_time = invincibility_time


func kill() -> void:
	player_killed.emit()
		
