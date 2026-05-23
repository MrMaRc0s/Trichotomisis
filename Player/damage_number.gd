extends Node3D

@onready var label_3d: Label3D = $Label3D

func setup(damage: int, color: Color, position: Vector3) -> void:
	label_3d.text = str(damage)
	label_3d.modulate = color
	label_3d.global_position = position
