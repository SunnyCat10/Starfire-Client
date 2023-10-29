extends Node2D

const FLAGPOLE_IDENTIFIER : String = "Flagpole"

var allied_team = {}
var enemy_team = {}

var ally_score : int = 0
var enemy_score : int = 0
var timer : Timer
# onready flag A
# onready flag B

@onready var ctf_ui : CanvasLayer = get_node("CTFGui")
@onready var objectives : Node = get_parent().get_node("%Objectives")

# for testing:
var client_team_id = 1

# for testsing
var timer_ready : bool = false

func _ready():
	setup_flags()
	# find spawn nodes
	pass


func _physics_process(delta):
	#if (timer_ready):
	#	ctf_ui.update_time(timer.time_left)
	pass


func setup_game(player_list):
	var player_id : int = multiplayer.get_unique_id()
	if (player_list["A"].has(player_id)):
		allied_team = player_list["A"]
		enemy_team = player_list["B"]
	else:
		allied_team = player_list["B"]
		enemy_team = player_list["A"]
	
	# set texture of the flags


func start_game():
	# CTF UI ENABLE
	# RUN TIMER LOCALLY
	pass


func end_game():
	pass


func update_score():
	pass
	

func setup_flags():
	for objective in objectives.get_children():
		if objective.name.contains(FLAGPOLE_IDENTIFIER):
			objective.setup_flag(client_team_id)
			objective.flag_picked.connect(on_pickup_flag)
			objective.flag_dropped.connect(on_drop_flag)
			objective.flag_captured.connect(on_capture_flag)


func on_pickup_flag(team_id : int):
	if client_team_id == team_id:
		ctf_ui.flag_taken(Server.Team.ALLY_TEAM)
	else:
		ctf_ui.flag_taken(Server.Team.ENEMY_TEAM)


func on_drop_flag(team_id : int):
	pass
	
func on_capture_flag(team_id : int):
	pass

func test():
	timer = Timer.new()
	timer.wait_time = 30.0
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer_ready = true
	await get_tree().create_timer(2).timeout
	ctf_ui.flag_captured(Server.Team.ALLY_TEAM)
	ctf_ui.flag_captured(Server.Team.ENEMY_TEAM)
	ctf_ui.flag_captured(Server.Team.ENEMY_TEAM)
	ctf_ui.flag_taken(Server.Team.ENEMY_TEAM)
	ctf_ui.flag_taken(Server.Team.ALLY_TEAM)
	await get_tree().create_timer(15).timeout
	ctf_ui.flag_returned(Server.Team.ENEMY_TEAM)
	ctf_ui.flag_returned(Server.Team.ALLY_TEAM)
