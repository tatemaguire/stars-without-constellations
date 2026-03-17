class_name Enemy
extends CharacterBody2D

@export var speed: float = 40

@export_group("Attack")
@export var damage: int = 1
@export var knockback_velocity: float = 250
@export_range(0, 90, 0.1, "radians_as_degrees") var knockback_angle: float = PI/8

@onready var attack_box: Area2D = $AttackBox

var direction: int = 1

func _physics_process(delta: float) -> void:
	_set_velocity(delta)
	move_and_slide()
	_check_direction_change()


# Sets velocity and gravity
func _set_velocity(delta: float) -> void:
	velocity.x = direction * speed
	velocity += get_gravity() * delta


# Turn around if on a wall or an edge
func _check_direction_change() -> void:
	var wall_normal: Vector2 = Vector2.ZERO
	if is_on_wall():
		wall_normal = get_wall_normal()
		
	if wall_normal.x < 0 or not $RightCast.is_colliding():
		# Wall is to the right
		direction = -1
		$AnimatedSprite2D.flip_h = true
	elif wall_normal.x > 0 or not $LeftCast.is_colliding():
		# Wall is to the left
		direction = 1
		$AnimatedSprite2D.flip_h = false


# Called when a collider body enters the attack box
func _on_attack_box_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		# Calculate right-facing knockback vector
		var knockback: Vector2 = Vector2.RIGHT.rotated(-knockback_angle)
		# Set knockback to push away from self
		var dx = body.global_position.x - self.global_position.x
		knockback.x *= sign(dx)
		body.take_damage(damage, knockback * knockback_velocity)
