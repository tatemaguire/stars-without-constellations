class_name HealthBox
extends Area2D

@export var initial_hp: int = 2
@export var invincibility_time: float = 0.2

@onready var hp: int = initial_hp
@onready var parent: Node2D = get_parent()

var invincible: bool = false
var remaining_invincibility_time: float = 0


func _process(delta: float) -> void:
	if invincible:
		remaining_invincibility_time -= delta
		if remaining_invincibility_time <= 0:
			invincible = false


## Deal damage to hp, pass knockback to parent if necessary
## Also asks parent if it can take damage
func take_damage(damage: int, knockback: Vector2) -> void:
	var can_take_damage = true
	if parent.has_method("can_take_damage"):
		can_take_damage = parent.can_take_damage()
	
	if not invincible and can_take_damage:
		hp -= damage
		if parent.has_method("take_damage"):
			parent.take_damage(damage, knockback)
		
		if hp <= 0:
			kill()

		invincible = true
		remaining_invincibility_time = invincibility_time


func kill() -> void:
	if parent.has_method("kill"):
		parent.kill()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "TheIsolation":
		take_damage(100, Vector2.ZERO)
