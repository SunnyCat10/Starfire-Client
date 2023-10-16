extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip : String = "127.0.0.1"
var port : int = 34684

var connected : bool = false

@onready var map : Node2D = get_node("/root/Map")

func _ready():
	connect_to_server()

func connect_to_server():
	network.create_client(ip, port)
	multiplayer.multiplayer_peer = network
	
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	
func on_connection_failed():
	print("Failed to connect")

func on_connected_to_server():
	print("Successfully connected")
	connected = true
 

@rpc
func get_location(location : Vector2):
	if (connected):
		rpc_id(1, "get_location", location)

@rpc func spawn_new_player(player_id : int, position : Vector2):
	map.spawn_new_player(player_id, position)
	
@rpc func despawn_player(player_id: int):
	map.despawn_player(player_id)
	
