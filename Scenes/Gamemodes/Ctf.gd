extends Node2D

const FLAGPOLE_IDENTIFIER : String = "Flagpole"

var allied_team = {}
var enemy_team = {}

var ally_score : int = 0
var enemy_score : int = 0
var timer : Timer
var _starting_time : float = 0.0

@onready var ctf_ui : CanvasLayer = get_node("CTFGui")
@onready var objectives : Node = get_parent().get_node("%Objectives")

var flagpoles = {}

# for testing:
var client_team_id

# for testsing
var timer_ready : bool = false


var status_update_cache = {}

func _ready():
	# setup_flags()
	Server.gamemode_started.connect(setup_game)
	Packets.gamemode_update.connect(append_status_update)


func _physics_process(delta):
	if not _starting_time == 0.0 and _starting_time <= Server.client_clock:
		if timer_ready:
			ctf_ui.update_time(timer.time_left)
		else:		
			timer.start()
			timer_ready = true
			setup_ctf_players()


	for status in status_update_cache:
		if status <= Server.client_clock:
			render_status(status_update_cache[status])
			ctf_ui.update_status(status_update_cache[status])
			status_update_cache.erase(status)


func setup_game(player_list, starting_time : float):
	var player_id : int = multiplayer.get_unique_id()
	if (player_list[Packets.CtfTeam.TEAM_A].has(player_id)):
		allied_team = player_list[Packets.CtfTeam.TEAM_A]
		enemy_team = player_list[Packets.CtfTeam.TEAM_B]
		client_team_id = Packets.CtfTeam.TEAM_A
	else:
		allied_team = player_list[Packets.CtfTeam.TEAM_B]
		enemy_team = player_list[Packets.CtfTeam.TEAM_A]
		client_team_id = Packets.CtfTeam.TEAM_B
	
	timer = Timer.new()
	print(starting_time, " > ",  Server.client_clock)
	timer.wait_time = 900.0 # TODO: send time duration while setting lobby
	timer.one_shot = true
	add_child(timer)
	_starting_time = starting_time
	setup_flags()
	
	ctf_ui.client_team_id = client_team_id


func end_game():
	pass


func setup_flags():
	for objective in objectives.get_children():
		if objective.name.contains(FLAGPOLE_IDENTIFIER):
			objective.setup_flag(client_team_id)
			objective.flag_picked.connect(on_pickup_flag)
			objective.flag_returned.connect(on_return_flag)
			objective.flag_captured.connect(on_capture_flag)
			flagpoles[objective.name] = objective


func on_pickup_flag(team_id : int):
	ctf_ui.flag_taken(Server.Team.ALLY_TEAM) if client_team_id == team_id else ctf_ui.flag_taken(Server.Team.ENEMY_TEAM)


func on_return_flag(team_id : int):
	ctf_ui.flag_returned(Server.Team.ALLY_TEAM) if client_team_id == team_id else ctf_ui.flag_returned(Server.Team.ENEMY_TEAM)


func on_capture_flag(team_id : int):
	ctf_ui.flag_captured(Server.Team.ALLY_TEAM) if client_team_id == team_id else ctf_ui.flag_captured(Server.Team.ENEMY_TEAM)


func append_status_update(status_info, status_time : float):
	status_update_cache[status_time] = status_info


func render_status(status_packet):
	if status_packet[Packets.StatusPacket.STATUS] == Packets.FlagStatus.FLAG_TAKEN:
		print("Rendering...")


func setup_ctf_players():
	for ally_player in allied_team:
		if not ally_player == multiplayer.get_unique_id():
			allied_team[ally_player] = get_parent().get_node(str(ally_player))
	for enemy_player in enemy_team:
		print(get_parent().get_node(str(enemy_player)))
	#print(enemy_team)

#func test():
#	timer = Timer.new()
#	timer.wait_time = 30.0
#	timer.one_shot = true
#	add_child(timer)
#	timer.start()
#	timer_ready = true
#	await get_tree().create_timer(2).timeout
#	ctf_ui.flag_captured(Server.Team.ALLY_TEAM)
#	ctf_ui.flag_captured(Server.Team.ENEMY_TEAM)
#	ctf_ui.flag_captured(Server.Team.ENEMY_TEAM)
#	ctf_ui.flag_taken(Server.Team.ENEMY_TEAM)
#	ctf_ui.flag_taken(Server.Team.ALLY_TEAM)
#	await get_tree().create_timer(15).timeout
#	ctf_ui.flag_returned(Server.Team.ENEMY_TEAM)
#	ctf_ui.flag_returned(Server.Team.ALLY_TEAM)
