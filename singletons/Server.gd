extends Node 

signal pinged(ping : float)
signal ui_update_player(name: String)
signal health_filled(health : int)
signal on_damage(damage : int)
signal lobby_list_initiated(lobby_list)
signal server_selected
signal lobby_selected(lobby_id : int)
signal lobby_gui_closed()
signal gamemode_started(team_list, starting_time : float)

const LOCAL_HOST_IP : String = "127.0.0.1"
const LOCAL_HOST_PORT : int = 34684

# for packets: TODO: Make a singleton for packets
const LOBBY_NAME = "n"
const LOBBY_GAMEMODE = "g"
const LOBBY_CURRENT_PLAYERS = "c"
const LOBBY_MAX_PLAYERS = "m"

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip : String = LOCAL_HOST_IP
var port : int = LOCAL_HOST_PORT

var connected : bool = false
var map : Node2D

var client_clock : float = 0
var latency_array = []
var latency : float = 0
var delta_latency = 0

var INTERPOLATION_OFFSET : float = 0.100 

enum Team {ALLY_TEAM, ENEMY_TEAM}

@rpc("any_peer", "unreliable_ordered") func recive_player_state(player_state): pass
@rpc("any_peer", "reliable") func player_joined_map(player_id : int): pass
@rpc("any_peer", "reliable") func fetch_server_time(client_time : float): pass
@rpc("any_peer") func determine_latency(client_time : float): pass
@rpc("any_peer", "reliable") func attack(position : Vector2, rotation : float, client_time : float): pass
@rpc("any_peer", "reliable") func get_lobby_list(): pass


func _ready():
	lobby_selected.connect(on_lobby_selected)


func _physics_process(delta):
	client_clock += delta + delta_latency
	delta_latency = 0

 
func connect_to_server():
	network.create_client(ip, port)
	multiplayer.multiplayer_peer = network
	
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.connected_to_server.connect(on_connected_to_server)


func on_connection_failed():
	print("Failed to connect")


func on_connected_to_server():
	print("Succesfully connected to the server")
	sync_time()
	#load_main_map()
	load_lobbies()
	connected = true


func load_lobbies():
	var lobby_selection : CanvasLayer = load("res://ui/LobbySelection.tscn").instantiate()
	add_child(lobby_selection)
	get_lobby_list.rpc_id(1)


# TODO: Later on ask the server type of map to select from a list
func on_lobby_selected(lobby_id : int):
	load_main_map()
	lobby_gui_closed.emit()


func load_main_map():
	var map_scene : PackedScene = load("res://Maps/map.tscn")
	map = map_scene.instantiate()
	get_parent().add_child(map)
	player_joined_map.rpc_id(1, multiplayer.get_unique_id())
	get_node("../Map/Player").set_physics_process(true)
	get_node("../Map/Player").name = str(multiplayer.get_unique_id())


func send_player_state(player_state):
	recive_player_state.rpc_id(1, player_state)
	
	
func sync_time():
	fetch_server_time.rpc_id(1, Time.get_unix_time_from_system())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(calculate_latency)
	self.add_child(timer)


func calculate_latency():
	determine_latency.rpc_id(1, Time.get_unix_time_from_system())


func send_attack(position : Vector2, rotation : float):
	attack.rpc_id(1, position, rotation, client_clock)


@rpc func spawn_new_player(player_id : int, position : Vector2):
	map.spawn_new_player(player_id, position)


@rpc func despawn_player(player_id: int):
	map.despawn_player(player_id)

@rpc("reliable") func update_ui_player(player_list: Dictionary):
	ui_update_player.emit(player_list)

@rpc("unreliable_ordered") func recive_world_state(world_state): 
	map.update_world_state(world_state)
	# print("Server: ", world_state["T"], " | Client: ", client_clock)


@rpc("reliable") func return_server_time(server_time : float, client_time : float):
	latency = (Time.get_unix_time_from_system() - client_time) / 2
	client_clock = server_time + latency


@rpc func return_latency(client_time : float):
	latency = (Time.get_unix_time_from_system() - client_time) / 2
	pinged.emit(latency)
	latency_array.append(latency)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		# print("New Latency ", latency)
		# print("Delta Latency ", delta_latency)
		latency_array.clear()
	

@rpc("reliable") func receive_attack(position : Vector2, rotation : float, client_time : float, player_id : int):
	if has_node(str(get_parent().get_path()) + "/Map/" + str(player_id)):
		if player_id == multiplayer.get_unique_id():
			pass
		else:
			get_node(str(get_parent().get_path()) + "/Map/" + str(player_id)).attack_dictionary[client_time] = {"Position": position, "Rotation": rotation}


@rpc("reliable") func receive_damage(damage: int): 
	on_damage.emit(damage)


@rpc("reliable") func receive_lobby_list(lobby_list):
	lobby_list_initiated.emit(lobby_list)


@rpc("reliable") func receive_ctf_start(sorted_player_list , start_time : float):
	gamemode_started.emit(sorted_player_list, start_time)


@rpc("reliable") func receive_gamemode_update(packet, event_time : float):
	Packets.gamemode_update.emit(packet, event_time)
