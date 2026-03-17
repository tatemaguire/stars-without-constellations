class_name AttackBox
extends Area2D

@export var damage: int = 1
## Is currently dealing damage
@export var attacking: bool = true: set = set_attacking

@export_group("Knockback")
## Deals knockback velocity on the target
@export var deals_knockback: bool = true
## How fast it gets knocked back
@export var knockback_velocity: float = 250
## The elevation angle of the knockback
@export_range(0, 90, 0.1, "radians_as_degrees") var knockback_angle: float = PI/8


var attack_visual: Sprite2D = null


func _ready() -> void:
	if has_node("AttackVisual"):
		attack_visual = get_node("AttackVisual")


func _on_area_entered(area: Area2D) -> void:
	if area is HealthBox:
		var knockback := Vector2.ZERO
		
		if deals_knockback:
			knockback = Vector2.RIGHT.rotated(-knockback_angle)
			# Set knockback to push away from self
			var dx = area.global_position.x - self.global_position.x
			knockback.x *= sign(dx)
			knockback *= knockback_velocity
		
		area.take_damage(damage, knockback)


func set_attacking(value: bool) -> void:
	if attack_visual:
		attack_visual.visible = value
	monitoring = value
