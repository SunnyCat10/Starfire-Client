extends Node2D

const FLAGPOLE_IDENTIFIER : String = "Flagpole"
const TEAM_A : int = 0
const TEAM_B : int = 1

enum Buffer {TIME, PACKET}

var allied_team = {}
var enemy_team = {}

var ally_score : int = 0
var enemy_score : int = 0
var timer : Timer
var _starting_time : float = 0.0

@onready var ctf_ui : CanvasLayer = get_node("CTFGui")
@onready var objectives : Node = get_parent().get_node("%Objectives")
@onready var flag_drop_scene: PackedScene = preload("res://Scenes/Drops/Flag.tscn")


var client_team_id : int

# for testsing
var timer_ready : bool = false

var flag_list = []
var status_update_cache = {} 
var packet_buffer = []
var indices_to_remove = []

var dropped_flags = {}

func _ready() -> void:
	Server.gamemode_started.connect(setup_game)
	Packets.gamemode_update.connect(append_status_update)


func _physics_process(delta) -> void:
	if not _starting_time == 0.0 and _starting_time <= Server.client_clock:
		if timer_ready:
			ctf_ui.update_time(timer.time_left)
		else:		
			timer.start()
			timer_ready = true
			setup_ctf_players()


	var updated_buffer = []
	for packet in packet_buffer:
		if packet[Buffer.TIME] <= Server.client_clock:
			render_status(packet[Buffer.PACKET])
		else:
			updated_buffer.append(packet)
	packet_buffer = updated_buffer


func setup_game(player_list, starting_time : float) -> void:
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


func end_game() -> void:
	pass


func setup_flags() -> void:
	var flag_id : int = 0
	for objective in objectives.get_children():
		if objective.name.contains(FLAGPOLE_IDENTIFIER):
			objective.setup_flag(client_team_id)
			objective.flag_picked.connect(on_pickup_flag)
			objective.flag_returned.connect(on_return_flag)
			objective.flag_captured.connect(on_capture_flag)
			flag_list.append(objective)
			objective.id = flag_id
			flag_id = flag_id + 1


func on_pickup_flag(team_id : int) -> void:
	ctf_ui.flag_taken(Server.Team.ALLY_TEAM) if client_team_id == team_id else ctf_ui.flag_taken(Server.Team.ENEMY_TEAM)


func on_return_flag(team_id : int) -> void:
	ctf_ui.flag_returned(Server.Team.ALLY_TEAM) if client_team_id == team_id else ctf_ui.flag_returned(Server.Team.ENEMY_TEAM)


func on_capture_flag(team_id : int) -> void:
	ctf_ui.flag_captured(Server.Team.ENEMY_TEAM) if client_team_id == team_id else ctf_ui.flag_captured(Server.Team.ALLY_TEAM)


func append_status_update(packet, event_time : float) -> void:
	print(packet)
	packet_buffer.append([event_time, packet])


func render_status(packet) -> void:
	# print(packet)
	match packet[Packets.PACKET_ID]:
		Packets.Type.PICKUP_FLAG:
			render_flag_pickup(packet)
		Packets.Type.CAPTURE_FLAG:
			render_flag_capture(packet)
		Packets.Type.SPAWN_PLAYER:
			spawn_player(packet)
		Packets.Type.PLAYER_DEATH:
			player_death(packet)
		Packets.Type.DROP_ITEM:
			drop_item(packet)
		Packets.Type.PICKUP_ITEM:
			item_pickup(packet)


func setup_ctf_players() -> void:
	for ally_player in allied_team:
		allied_team[ally_player] = get_parent().get_node(str(ally_player))
		allied_team[ally_player].flag_manager.setup_manager(client_team_id, client_team_id)
	for enemy_player in enemy_team:
		var enemy_team_id = 1 if client_team_id == 0 else 0
		enemy_team[enemy_player] = get_parent().get_node(str(enemy_player))
		enemy_team[enemy_player].flag_manager.setup_manager(enemy_team_id, client_team_id)


func render_flag_pickup(packet) -> void:
	var flag = flag_list[packet[Packets.PickupFlag.FLAG_ID]]
	var player_id : int = packet[Packets.PickupFlag.PLAYER_ID]
	flag.pickup_flag()
	if allied_team.has(player_id):
		allied_team[player_id].flag_manager.pickup(flag)
	if enemy_team.has(player_id):
		enemy_team[player_id].flag_manager.pickup(flag)


func render_flag_capture(packet) -> void:
	var flag = flag_list[packet[Packets.CaptureFlag.FLAG_ID]]
	var player_id : int = packet[Packets.CaptureFlag.PLAYER_ID]
	flag.capture_flag()
	if allied_team.has(player_id):
		allied_team[player_id].flag_manager.drop_flag()
	elif enemy_team.has(player_id):
		enemy_team[player_id].flag_manager.drop_flag()


func spawn_player(packet) -> void:
	var player_id : int = packet[Packets.SpawnPlayer.PLAYER_ID]
	var spawn_location : Vector2 = packet[Packets.SpawnPlayer.SPAWN_LOCATION]
	if allied_team.has(player_id):
		allied_team[player_id].spawn(spawn_location)
	elif enemy_team.has(player_id):
		enemy_team[player_id].spawn(spawn_location)


func player_death(packet) -> void:
	var player_id : int = packet[Packets.PlayerDeath.PLAYER_ID]
	if allied_team.has(player_id):
		allied_team[player_id].death()
	elif enemy_team.has(player_id):
		enemy_team[player_id].death()


func drop_item(packet) -> void:
	var item_type : int = packet[Packets.DropItem.ITEM_TYPE]
	var item_id : int = packet[Packets.DropItem.ITEM_ID]
	var drop_location : Vector2 = packet[Packets.DropItem.DROP_LOCATION]
	if (item_type == 0):
		var player_id : int = packet[Packets.DropItem.PLAYER_ID]
		remove_player_flag(player_id)
		create_drop_flag(drop_location, item_id)


func create_drop_flag(drop_position : Vector2, team_id : int) -> void:
	var flag_drop : Node2D = flag_drop_scene.instantiate()
	add_child(flag_drop)
	flag_drop.global_position = drop_position
	flag_drop.load_flag(client_team_id, team_id)
	dropped_flags[team_id] = flag_drop


func item_pickup(packet):
	var item_type : Packets.ItemType = packet[Packets.PickupItem.ITEM_TYPE]
	var item_id : int = packet[Packets.PickupItem.ITEM_ID]
	var player_id : int = packet[Packets.PickupItem.PLAYER_ID]
	
	if item_type == Packets.ItemType.FLAG:
		var flag_index : int = 0
		for objective in flag_list:
			if objective.flag_team_id == item_id:
				break
			flag_index += 1
		
		if item_id == get_player_team_id(player_id):
			remove_player_flag(player_id)
			flag_list[flag_index].return_flag()
		else:
			var return_flag_packet = [Packets.PickupFlag, player_id, flag_index]
			render_flag_pickup(return_flag_packet) # TODO: make generic function instead of packet
		dropped_flags[item_id].queue_free()
		dropped_flags[item_id] = null


func get_player_team_id(player_id : int) -> int:
	if client_team_id == TEAM_A:
		return TEAM_A if allied_team.has(player_id) else TEAM_B
	else:
		return TEAM_B if allied_team.has(player_id) else TEAM_A


func remove_player_flag(player_id : int) -> void:
	if allied_team.has(player_id):
		allied_team[player_id].flag_manager.drop_flag()
	elif enemy_team.has(player_id):
		enemy_team[player_id].flag_manager.drop_flag()
	else:
		pass


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
