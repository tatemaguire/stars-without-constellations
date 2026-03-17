class_name PlayerCharacter 
extends CharacterBody2D

enum States {GROUND, JUMPING, FALLING, COYOTE, DEAD}


@export_group("Movement")
## Max player speed 
@export var max_speed: float = 70
## Forward acceleration
@export var acceleration: float = 600
## Acceleration when slowing down
@export var damping: float = 500
## Acceleration due to gravity
@export var gravity: float = 600
## Velocity of jump, applied upwards
@export var jump_velocity: float = 180
## Acceleration downwards if jump ends early
@export var jump_suppression_acceleration: float = 70
## Time in s of coyote effect (jumping after running off edge)
@export var coyote_time: float = 0.08

@export_group("Health and Attack")
## Time in s of invinsibility after taking damage
@export var attack_time: float = 0.2


# State Variables
# The following variables describe the player's state
var current_state: States = States.FALLING
var remaining_coyote_time: float = 0
var direction: float = 0
var suppress_jump: bool = false
var attacking: bool = false
var remaining_attack_time: float = 0
var facing_left: bool = false: set = set_facing_left
		
		
@onready var health_box: HealthBox = $HealthBox


signal player_damaged(current_health: int)
signal player_killed


func _ready() -> void:
	player_killed.connect(SceneTransitions._on_player_killed)


func _process(delta: float) -> void:
	_update_attack(delta)


func _physics_process(delta: float) -> void:
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
			$AnimatedSprite2D.play("fall")
		States.COYOTE:
			_parse_input(delta)
			_apply_gravity(delta)
			_apply_damping(delta)
			remaining_coyote_time -= delta
		States.DEAD:
			_apply_gravity(delta)
			_apply_damping(delta)
			facing_left = velocity.x < 0


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
			player_killed.emit()
			$AnimatedSprite2D.play("death")
	
	current_state = new_state


# Function that's called during many states where player has control
# updates the direction variable
func _parse_input(delta: float) -> void:
	direction = Input.get_axis("Left", "Right")
	
	# Sprite orientation
	if direction < 0:
		facing_left = true
	elif direction > 0:
		facing_left = false

	# Horizontal movement
	if direction != 0:
		var target_velocity = sign(direction) * max_speed
		var accel = abs(direction) * acceleration
		velocity.x = move_toward(velocity.x, target_velocity, accel * delta)


## Applies custom gravity
func _apply_gravity(delta: float) -> void:
	velocity.y += gravity * delta


## Applies damping to horizontal velocity
func _apply_damping(delta: float) -> void:
	if absf(direction) < 1e-4 or sign(direction) == -sign(velocity.x):
		velocity.x = move_toward(velocity.x, 0, damping * delta)


## Jump down through platforms
func _jump_down() -> void:
	position.y += 1


## Parses input to activate AttackBox for attack_time
func _update_attack(delta: float) -> void:
	if current_state == States.DEAD:
		return
	# Check that attack is being made
	if Input.is_action_just_pressed("Attack") and not attacking:
		remaining_attack_time = attack_time
		attacking = true
	
	# Deal damage and decrease timer
	if attacking:
		remaining_attack_time -= delta
		if remaining_attack_time < 0:
			attacking = false
	
	$AttackBox.attacking = attacking


## Returns true if the player is in a state where they can get damaged
func can_take_damage() -> bool:
	return current_state != States.DEAD


## Processes damage dealt to HealthBox
## Emits signal and applies knockback
func take_damage(_damage: int, knockback: Vector2 = Vector2.ZERO) -> void:
	velocity = knockback
	player_damaged.emit($HealthBox.hp)


func kill() -> void:
	_transition_state(States.DEAD)


## Updates player and attack sprites when flipping direction
func set_facing_left(value: bool) -> void:
	$AnimatedSprite2D.flip_h = value
	$AttackBox.position.x = 1 if value else 7
	$AttackBox.scale.x = -1 if value else 1
