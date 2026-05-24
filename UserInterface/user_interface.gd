extends Control

@onready var health_bar: TextureProgressBar = %HealthBar

@export var player : Player

func update_health() -> void:
	health_bar.max_value = player.health_component.max_health
	health_bar.value = player.health_component.current_health
