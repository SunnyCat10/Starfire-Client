extends CanvasLayer

@onready var lobby_list : ItemList = %LobbyList
@onready var join_game_btn : Button = %JoinGame

var list = {}
var lobby_indices = {}

func _ready():
	Server.lobby_list_initiated.connect(initiate_list)
	join_game_btn.pressed.connect(join_game)
	Server.lobby_gui_closed.connect(close)


func render_list():
	for lobby in list:
		var selectable : bool = false if list[lobby][Server.LOBBY_CURRENT_PLAYERS] == list[lobby][Server.LOBBY_MAX_PLAYERS] else true
		var index : int = lobby_list.add_item(decode_packet(list[lobby]), null, selectable)
		lobby_indices[lobby] = index
	Server.server_selected.emit()


func decode_packet(packet):
	return "⏣ " + str(packet[Server.LOBBY_NAME]) + " [" + str(packet[Server.LOBBY_GAMEMODE]) + "] (" + str(packet[Server.LOBBY_CURRENT_PLAYERS]) + "/" + str(packet[Server.LOBBY_MAX_PLAYERS]) + ")"


func initiate_list(packet):
	list = packet
	render_list()


func join_game():
	if lobby_list.is_anything_selected():
		var index : int = lobby_list.get_selected_items()[0]
		for lobby in lobby_indices:
			if lobby_indices[lobby] == index:
				Server.lobby_selected.emit(lobby.to_int())
				break


func close():
	queue_free()
