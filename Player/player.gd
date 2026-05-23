extends CharacterBody3D
class_name Player


const JUMP_VELOCITY = 4.5
const DECAY := 8.0

# Stores the x/y direction the player is trying to look in
var _look := Vector2.ZERO

# Stores rge direction the player moves then attacking
var _attack_direction := Vector3.ZERO

@export_category("Animation")
@export var animation_decay : float = 20
@export var attack_move_speed : float = 3

@export_category("Camera")
@export var mouse_sensitivity : float = 0.00075
@export var min_boundary : float = -60
@export var max_boundary : float = 10

@export_category("RPG Stats")
@export var stats : CharacterStats
@export var base_damage = 10.0

@onready var horizontinal_pivot: Node3D = $HorizontinalPivot
@onready var vertical_pivot: Node3D = $HorizontinalPivot/VerticalPivot
@onready var rig_pivot: Node3D = $RigPivot
@onready var rig: Node3D = $RigPivot/Rig
@onready var attack_cast: RayCast3D = %AttackCast
@onready var health_component: HealthComponent = $HealthComponent
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var area_attack: ShapeCast3D = $RigPivot/AreaAttack


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$SmoothCameraArm.add_excluded_object(self.get_rid())
	health_component.update_max_health(30)
	
func _physics_process(delta: float) -> void:
	frame_camera_rotation()

	var direction := get_movement_direction()
	
	rig.update_animation_tree(direction)
	
	handle_idle_physics_frame(delta, direction)
	handle_attacking_physics_frame(delta)
	handle_heavy_attacking_physics_frame()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	move_and_slide()
	
func handle_idle_physics_frame(delta: float, direction: Vector3) -> void:
	if not rig.is_idle() and not rig.is_dashing():
		return
		
	velocity.x = expenential_decay(velocity.x, direction.x * stats.get_base_speed(), DECAY, delta)
	velocity.z = expenential_decay(velocity.z, direction.z * stats.get_base_speed(), DECAY, delta)

	if direction:
		look_toward_direction(direction, delta)
	
func handle_attacking_physics_frame(delta: float) -> void:
	if not rig.is_attacking():
		return
	velocity.x = _attack_direction.x * attack_move_speed
	velocity.z = _attack_direction.z * attack_move_speed
	look_toward_direction(_attack_direction, delta)
	attack_cast.deal_damage(base_damage + stats.get_base_strenght())
	
func handle_heavy_attacking_physics_frame() -> void:
	if not rig.is_heavy_attacking():
		return
	velocity.x = 0
	velocity.z = 0
	
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
		if event.is_action_pressed("heavy_attack"):
			rig.travel("Overhead")
			
#	if event.is_action_pressed("debug_level_up"):
#		stats.xp+=10000

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
	_attack_direction = get_movement_direction()
	if _attack_direction.is_zero_approx():
		_attack_direction = rig.global_basis * Vector3(0, 0, 1)
	attack_cast.clear_exceptions()
	


func _on_health_component_defeat() -> void:
	rig.travel("Defeat")
	collision_shape_3d.disabled = true
	set_physics_process(false)


func _on_rig_heavy_attack() -> void:
	area_attack.deal_damage(base_damage*2 + stats.get_base_strenght())
	
func expenential_decay(a: float, b:float, decay: float, delta: float) -> float:
	return b + (a - b) * exp(-decay * delta)
