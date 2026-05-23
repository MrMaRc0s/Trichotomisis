extends Node3D

const DAMAGE_NUMBER = preload("uid://bljtqqtanrofb")

func spawn_damage_number(damage: int, color: Color, position: Vector3) -> void:
	var new_number = DAMAGE_NUMBER.instantiate()
	new_number.setup(damage, color, position)
	add_child(new_number)
