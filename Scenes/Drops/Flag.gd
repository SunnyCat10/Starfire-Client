extends Area2D

@onready var flag : Sprite2D = %Flag

var ally_flag_texture : Texture2D = preload("res://assets/Drops/ally_team_flag_dropped.png")
var enemy_flag_texture : Texture2D = preload("res://assets/Drops/enemy_team_flag_dropped.png")

var _flag_team_id : int
var _client_team_id : int
var _flagpole : Node2D


func _ready():
	body_entered.connect(on_body_entered)


func load_flag(flagpole : Node2D, client_team_id : int, flag_team_id : int):
	_client_team_id = client_team_id
	_flag_team_id = flag_team_id
	_flagpole = flagpole
	if (client_team_id == flag_team_id):
		flag.texture = ally_flag_texture
	else:
		flag.texture = enemy_flag_texture


func take_flag(body: Node2D):
	body.flag_manager.load_flag(_flagpole, _client_team_id)
	self.queue_free()


func return_flag():
	_flagpole.return_flag
	self.queue_free()


func on_body_entered(body: Node2D):
	if body.is_in_group("client_player"):
		if not _client_team_id == _flag_team_id:
			take_flag(body)
		else:
			return_flag()
