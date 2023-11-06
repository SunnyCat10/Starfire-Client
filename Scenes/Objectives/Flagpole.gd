extends Area2D

signal flag_picked(team_id : int)
signal flag_captured(team_id : int)
signal flag_returned(team_id : int)

var _client_team_id : int

@export var flag_team_id : int

@onready var flag : Sprite2D = get_node("%Flag")

var ally_flag_texture : Texture2D = preload("res://assets/Environment/Objectives/ally_team_flag.png")
var enemy_flag_texture : Texture2D = preload("res://assets/Environment/Objectives/enemy_team_flag.png")
var empty_flag_texture : Texture2D = preload("res://assets/Environment/Objectives/empty_flagpole.png")


var is_empty : bool = false
var id : int

func _ready():
	body_entered.connect(on_body_entered)


func setup_flag(client_team_id : int):
	_client_team_id = client_team_id
	if (client_team_id == flag_team_id):
		flag.texture = ally_flag_texture
	else:
		flag.texture = enemy_flag_texture
	is_empty = false


#func pickup_flag(player : Node2D):
#	flag_picked.emit(flag_team_id)
#	flag.texture = empty_flag_texture
#	is_empty = true


func pickup_flag():
	flag_picked.emit(flag_team_id)
	flag.texture = empty_flag_texture


func capture_flag():
	flag_captured.emit(flag_team_id)


func return_flag(client_team_id : int):
	flag_returned.emit(flag_team_id)
	setup_flag(client_team_id)
	is_empty = false


func on_body_entered(body: Node2D):
	pass
#	if body.is_in_group("client_player"):
#		if not _client_team_id == flag_team_id and not is_empty:
#			print("took the flag")
#			pickup_flag(body)
#			body.flag_manager.load_flag(self, _client_team_id)
#		if _client_team_id == flag_team_id and body.flag_manager.with_flag:
#			body.flag_manager.capture_flag()
#			capture_flag()
