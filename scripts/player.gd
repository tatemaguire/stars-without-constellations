class_name PlayerCharacter extends CharacterBody2D

enum States {GROUND, JUMPING, FALLING, COYOTE}


@export var max_speed: float = 80
## Forward acceleration
@export var acceleration: float = 700
## Acceleration when slowing down
@export var drift: float = 900
## Velocity of jump, applied upwards
@export var jump_velocity: float = 190
## Time in ms of coyote effect (jumping after running off edge)
@export var coyote_time: float = 0.05

var current_state: States = States.FALLING
var remaining_coyote_time: float = 0

func _physics_process(delta: float) -> void:
	_process_state(delta)
	_check_state_transitions()
	move_and_slide()


func _check_jump(_delta: float) -> void:
	# Get jump input
	if is_on_floor() and Input.is_action_just_pressed("Jump"):
		if Input.is_action_pressed("Down"):
			jump_down()
		else:
			velocity.y = -jump_velocity


func _process_state(delta: float) -> void:
	match current_state:
		States.GROUND:
			var direction = _parse_input(delta)
			if direction != 0:
				$AnimatedSprite2D.play("run")
			else:
				$AnimatedSprite2D.play("idle")
		States.JUMPING:
			_parse_input(delta)
			_apply_gravity(delta)
		States.FALLING:
			_parse_input(delta)
			_apply_gravity(delta)
		States.COYOTE:
			_parse_input(delta)
			_apply_gravity(delta)
			remaining_coyote_time -= delta


# For each state, check the conditions for transitioning
# Important that only one of these is called per frame (if elif elif else)
func _check_state_transitions():
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
				_transition_state(States.FALLING)
		States.FALLING:
			if is_on_floor():
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
	# On leaving this state
	#match: current_state
	
	# On entering new_state
	match new_state:
		States.JUMPING:
			if Input.is_action_pressed("Down"):
				jump_down()
			else:
				velocity.y = -jump_velocity
		States.COYOTE:
			remaining_coyote_time = coyote_time
	
	current_state = new_state


# Function that's called during many states where player has control
# Returns direction
func _parse_input(delta: float) -> float:
	var direction := Input.get_axis("Left", "Right")
	
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false
	acceleration
	if direction != 0:
		var target_velocity = sign(direction) * max_speed
		var accel = abs(direction) * acceleration
		velocity.x = move_toward(velocity.x, target_velocity, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, drift * delta)
	
	return direction

func _apply_gravity(delta: float) -> void:
	velocity += get_gravity() * delta

func jump_down() -> void:
	position.y += 1
