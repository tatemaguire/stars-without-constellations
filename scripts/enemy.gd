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


func _on_attack_box_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		# Calculate right-facing knockback vector
		var knockback: Vector2 = Vector2.RIGHT.rotated(-knockback_angle)
		# Set knockback to push away from self
		var dx = body.global_position.x - self.global_position.x
		knockback.x *= sign(dx)
		body.take_damage(damage, knockback * knockback_velocity)
