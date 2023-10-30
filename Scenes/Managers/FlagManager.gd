extends Node2D

var _flagpole : Node2D
var _client_team_id : int
var with_flag : bool = false

func load_flag(flagpole : Node2D, client_team_id : int):
	_flagpole = flagpole
	_client_team_id = client_team_id
	with_flag = true


func drop_flag():
	pass
	with_flag = false

func capture_flag():
	_flagpole.setup_flag(_client_team_id)
	pass
	with_flag = false
