extends Node
class_name HealthComponent

signal defeat()
signal health_changed()

@export var body : PhysicsBody3D

var max_health: float
var current_health: float:
	set(value):
		current_health = max(value, 0)
		if current_health ==0:
			defeat.emit()
		health_changed.emit()

func update_max_health(max_hp: float) ->void:
	max_health = max_hp
	current_health = max_health

func take_damage(damage: float, critical: bool) -> void:
	var damage_in = damage
	var color = Color.WHITE
	if critical:
		damage_in = damage*2.0
		color = Color.RED
	current_health -= damage_in
	VfxManager.spawn_damage_number(damage_in, color, body.global_position)
