extends CharacterBody2D

signal health_changed
signal player_dead

const RADIANS_EQUAL_APPROX : float = PI/64

@export var speed : int
@export var rotation_speed : float
@export var attack_cooldown : float
@export var healthint : int
@export var turret_rotation_speed : float

var can_shoot = true
var alive = true
var tank_direction : Vector2 = Vector2()

@onready var mouse_pos_gizmo : Polygon2D = $MousePositionGizmo
@onready var selected_rot_gizmo : Polygon2D = $SelectedRotationGizmo
@onready var unselected_rot_gizmo : Polygon2D = $UnselectedRotationGizmo
@onready var tank_direction_gizmo : Polygon2D = $TankDirectionGizmo
@onready var turret : Node2D = $Turret

func _ready():
	$AttackTimer.wait_time = attack_cooldown
	tank_direction = Vector2(1,0)
	tank_direction_gizmo.position = tank_direction * 20

func control(delta):
	
	
	
	rotate_turret(delta)
	
	
	
	var rotation_direction : float = 0
	if Input.is_action_pressed('turn_right'):
		rotation_direction += 1
	if Input.is_action_pressed('turn_left'):
		rotation_direction -= 1
	var rotation_offset : float = rotation_speed * rotation_direction * delta
	rotation += rotation_offset
	
	velocity = Vector2()
	if Input.is_action_pressed('move_forward'):
		velocity = Vector2(speed, 0).rotated(rotation)
	if Input.is_action_pressed('move_backward'):
		velocity = Vector2(-speed/2.0, 0).rotated(rotation)

func _physics_process(delta):
	if not alive:
		return
	control(delta)
	move_and_slide()
	tank_direction = Vector2(1,0)

func rotate_turret(delta):
	var target_angle : float = turret.get_angle_to(get_global_mouse_position())
	if (target_angle >= -RADIANS_EQUAL_APPROX and target_angle <= RADIANS_EQUAL_APPROX):
		return
	if (target_angle >= 0):
		turret.rotation += PI * delta
	else:
		turret.rotation -= PI * delta

func rotate_turret_2(delta):
	var target_direction : Vector2 = get_local_mouse_position().normalized()
	
	
	mouse_pos_gizmo.position = target_direction * 24
	
	
	print(tank_direction)
	var right_point : Vector2 = to_local(tank_direction.rotated(PI / 2 * 1 * delta)).normalized()
	var left_point : Vector2 = to_local(tank_direction.rotated(PI / 2 * -1 * delta)).normalized()
	
	print("right: ", right_point)
	print("left: ", left_point)
	
	if target_direction.distance_squared_to(right_point) <= target_direction.distance_squared_to(left_point):
		selected_rot_gizmo.position = right_point * 20
		unselected_rot_gizmo.position = left_point * 20
		tank_direction = right_point
		$Turret.look_at(to_global(right_point))
		tank_direction_gizmo.position = tank_direction * 22
	else:
		selected_rot_gizmo.position = left_point * 20
		unselected_rot_gizmo.position = right_point * 20
		tank_direction = left_point
		$Turret.look_at(to_global(left_point))
		tank_direction_gizmo.position = tank_direction * 22
	
	#print("target: ", target_direction)
	print("tank: ", tank_direction)
	
	
