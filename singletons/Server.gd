extends Node 

const LOCAL_HOST_IP : String = "127.0.0.1"
const LOCAL_HOST_PORT : int = 34684

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip : String = LOCAL_HOST_IP
var port : int = LOCAL_HOST_PORT

var connected : bool = false
var map : Node2D

@rpc("any_peer", "unreliable_ordered") func recive_player_state(player_state): pass
@rpc("any_peer", "reliable") func player_joined_map(player_id : int): pass


func connect_to_server():
	network.create_client(ip, port)
	multiplayer.multiplayer_peer = network
	
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.connected_to_server.connect(on_connected_to_server)


func on_connection_failed():
	print("Failed to connect")


func on_connected_to_server():
	print("Successfully connected")
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


@rpc func spawn_new_player(player_id : int, position : Vector2):
	map.spawn_new_player(player_id, position)


@rpc func despawn_player(player_id: int):
	map.despawn_player(player_id)


@rpc("unreliable_ordered") func recive_world_state(world_state): 
	map.update_world_state(world_state)

