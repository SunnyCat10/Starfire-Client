extends CanvasLayer

@onready var lobby_list = %LobbyList

var list = {}


func _ready():
	Server.lobby_list_initiated.connect(initiate_list)


func render_list():
	for lobby in list:
		var selectable : bool = false if list[lobby][Server.LOBBY_CURRENT_PLAYERS] == list[lobby][Server.LOBBY_MAX_PLAYERS] else true
		lobby_list.add_item(decode_packet(list["1"]), null, selectable)


func decode_packet(packet):
	return "⏣ " + packet[Server.LOBBY_NAME] + " [" + packet[Server.LOBBY_GAMEMODE] + "] (" + packet[Server.LOBBY_CURRENT_PLAYERS] + "/" + packet[Server.LOBBY_MAX_PLAYERS] + ")"


func initiate_list(packet):
	list = packet
	render_list()
