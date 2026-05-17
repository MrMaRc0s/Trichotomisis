extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Stores the x/y direction the player is trying to look in
var _look := Vector2.ZERO

@export var mouse_sensitivity : float = 0.00075
@export var min_boundary : float = -60
@export var max_boundary : float = 10
@export var animation_decay : float = 20

@onready var horizontinal_pivot: Node3D = $HorizontinalPivot
@onready var vertical_pivot: Node3D = $HorizontinalPivot/VerticalPivot
@onready var rig_pivot: Node3D = $RigPivot
@onready var rig: Node3D = $RigPivot/Rig


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$SmoothCameraArm.add_excluded_object(self.get_rid())
	
func _physics_process(delta: float) -> void:
	frame_camera_rotation()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := get_movement_direction()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		look_toward_direction(direction, delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	rig.update_animation_tree(direction)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			return
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_look += -event.relative * mouse_sensitivity
			
	if rig.is_idle():
		if event.is_action_pressed("attack"):
			slash_attack()

func get_movement_direction() -> Vector3:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_vector := Vector3(input_dir.x, 0, input_dir.y).normalized()
	var direction := horizontinal_pivot.global_transform.basis * input_vector
	return direction

func frame_camera_rotation() -> void:
	horizontinal_pivot.rotate_y(_look.x)
	vertical_pivot.rotate_x(_look.y)
	
	vertical_pivot.rotation.x = clampf(vertical_pivot.rotation.x, deg_to_rad(min_boundary), deg_to_rad(max_boundary))
	
	_look = Vector2.ZERO
	
func look_toward_direction(direction: Vector3, delta: float) -> void:
	var target_transform := rig_pivot.global_transform.looking_at(rig_pivot.global_position + direction, Vector3.UP, true)
	rig_pivot.global_transform = rig_pivot.global_transform.interpolate_with(target_transform, 1.0-exp(-animation_decay * delta))
	
func slash_attack() -> void:
	rig.travel("Slash")
