extends Area2D

signal flag_picked(team_id : int)
signal flag_dropped(team_id : int)
signal flag_captured(team_id : int)

var _client_team_id : int

@export var flag_team_id : int

@onready var flag : Sprite2D = get_node("%Flag")

var ally_flag_texture : Texture2D = preload("res://assets/Environment/Objectives/ally_team_flag.png")
var enemy_flag_texture : Texture2D = preload("res://assets/Environment/Objectives/enemy_team_flag.png")
var empty_flag_texture : Texture2D = preload("res://assets/Environment/Objectives/empty_flagpole.png")

var empty_flag_pole : Sprite2D

func _ready():
	body_entered.connect(on_body_entered)


func setup_flag(client_team_id : int):
	_client_team_id = client_team_id
	if (client_team_id == flag_team_id):
		flag.texture = ally_flag_texture
	else:
		flag.texture = enemy_flag_texture


func pickup_flag(player : Node2D):
	flag_picked.emit(flag_team_id)
	empty_flagpole()
	set_deferred("monitoring", false)
	get_parent().call_deferred("remove_child", self)
	position = Vector2.ZERO
	rotation = -PI/2
	player.call_deferred("add_child", self)
	

func drop_flag():
	pass


func capture_flag():
	pass


func empty_flagpole():
	empty_flag_pole = Sprite2D.new()
	empty_flag_pole.position = flag.global_position
	empty_flag_pole.texture = empty_flag_texture
	get_parent().add_child(empty_flag_pole)


func on_body_entered(body: Node2D):
	if body.is_in_group("client_player"):
		if not _client_team_id == flag_team_id:
			print("Here!")
			pickup_flag(body)
