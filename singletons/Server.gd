extends Node 

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip : String = "46.116.208.172" #"127.0.0.1"
var port : int = 2557 #34684

var connected : bool = false

@onready var map : Node2D = get_node("/root/Map")

@rpc("any_peer", "unreliable_ordered") func recive_player_state(player_state) : pass

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
	get_node("../Map/CharacterBody2D").set_physics_process(true) # remove when we get a menu
 

@rpc func spawn_new_player(player_id : int, position : Vector2):
	map.spawn_new_player(player_id, position)
	
@rpc func despawn_player(player_id: int):
	map.despawn_player(player_id)

func send_player_state(player_state):
#	print(player_state)
	recive_player_state.rpc_id(1, player_state)
	
@rpc("unreliable_ordered") func recive_world_state(world_state): 
#	print(world_state)
	map.update_world_state(world_state)
	
