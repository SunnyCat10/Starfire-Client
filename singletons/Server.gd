extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip : String = "127.0.0.1"
var port : int = 34684

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
	print(self.is_multiplayer_authority())
	
