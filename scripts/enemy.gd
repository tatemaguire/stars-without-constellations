extends RigidBody2D

@export var speed: float = 40

var direction: int = 1

func _ready() -> void:
	$AnimatedSprite2D.play("run")


func _physics_process(_delta: float) -> void:
	if direction == -1 and $LeftCast.is_colliding():
		direction = 1
		$AnimatedSprite2D.flip_h = false
	elif direction == 1 and $RightCast.is_colliding():
		direction = -1
		$AnimatedSprite2D.flip_h = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity.x = direction * speed
