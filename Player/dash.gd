extends Node3D

@export var player : Player
@export var speed_multiplier : float = 3

@onready var cooldown: Timer = $Cooldown


var direction := Vector3.ZERO
var dash_duration := 0.1
var time_remaining := 0

func _unhandled_input(event: InputEvent) -> void:
	if not cooldown.is_stopped():
		return
	
	if event.is_action_pressed("dash"):
		direction = player.get_movement_direction()
		if not direction.is_zero_approx():
			cooldown.start(1)
			time_remaining = dash_duration
			player.rig.travel("Dash")

func _physics_process(delta: float) -> void:
	if direction.is_zero_approx():
		return
	
	player.velocity = direction * player.SPEED * speed_multiplier
	time_remaining -= delta
	if time_remaining<=0:
		direction = Vector3.ZERO
