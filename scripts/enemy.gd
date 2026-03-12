extends RigidBody2D

@export var speed: float = 40
@export var damage: int = 1
@export var knockback_velocity: float = 200

var direction: int = 1

func _ready() -> void:
	$AnimatedSprite2D.play("run")
	contact_monitor = true
	max_contacts_reported = 4


func _physics_process(_delta: float) -> void:
	if direction == 0:
		printerr("ENEMY STAGNANT")
	# Change direction when run into wall
	if $LeftCast.is_colliding():
		direction = 1
		$AnimatedSprite2D.flip_h = false
	if $RightCast.is_colliding():
		direction = -1
		$AnimatedSprite2D.flip_h = true
	
	# Check collisions
	for body in get_colliding_bodies():
		if body is PlayerCharacter:
			# calculate knockback velocity
			var knockback: Vector2 = (body.global_position - self.global_position).normalized()
			knockback = knockback.normalized() * knockback_velocity
			# apply damage and knockback
			body.take_damage(damage, knockback)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity.x = direction * speed
