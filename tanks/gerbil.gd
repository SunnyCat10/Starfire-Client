extends CharacterBody2D

signal health_changed
signal player_dead

const RADIANS_EQUAL_APPROX : float = PI/64

@export var speed : int
@export var rotation_speed : float
@export var attack_cooldown : float
@export var healthint : int

var can_shoot = true
var alive = true
var tank_direction : Vector2 = Vector2()

@export_range(0.0, 2) var turret_weight : float  = 1
@onready var turret : Node2D = $Turret

var player_state

func _ready():
	set_physics_process(false) #remove when we will add a menu
	$AttackTimer.wait_time = attack_cooldown
	tank_direction = Vector2(1,0)

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
	define_player_state()

func rotate_turret(delta):
	var target_angle : float = turret.get_angle_to(get_global_mouse_position())
	if (target_angle >= -RADIANS_EQUAL_APPROX and target_angle <= RADIANS_EQUAL_APPROX):
		return
	var rotation_range = (PI * delta) * turret_weight
	if (target_angle >= 0):
		turret.rotation += rotation_range
	else:
		turret.rotation -= rotation_range

func define_player_state():
	player_state = {"T" : Time.get_unix_time_from_system(),
	"P" : global_position, 
	"R" : rotation,
	"r" : turret.rotation}
	Server.send_player_state(player_state)
	
