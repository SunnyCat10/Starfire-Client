extends Node 

signal pinged(ping : float)

const LOCAL_HOST_IP : String = "127.0.0.1"
const LOCAL_HOST_PORT : int = 34684

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip : String = LOCAL_HOST_IP
var port : int = LOCAL_HOST_PORT

var connected : bool = false
var map : Node2D

var client_clock : float = 0
var latency_array = []
var latency : float = 0
var delta_latency = 0

@rpc("any_peer", "unreliable_ordered") func recive_player_state(player_state): pass
@rpc("any_peer", "reliable") func player_joined_map(player_id : int): pass
@rpc("any_peer", "reliable") func fetch_server_time(client_time : float): pass
@rpc("any_peer") func determine_latency(client_time : float): pass


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
	load_main_map()
	connected = true


func load_main_map():
	var map_scene : PackedScene = load("res://Maps/map.tscn")
	map = map_scene.instantiate()
	get_parent().add_child(map)
	print(multiplayer.get_unique_id())
	player_joined_map.rpc_id(1, multiplayer.get_unique_id())
	get_node("../Map/CharacterBody2D").set_physics_process(true)
	get_node("../ServerSelection").queue_free()


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


@rpc func spawn_new_player(player_id : int, position : Vector2):
	map.spawn_new_player(player_id, position)


@rpc func despawn_player(player_id: int):
	map.despawn_player(player_id)


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
	
