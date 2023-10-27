extends CanvasLayer


@onready var fps_label : Label = $MarginContainer/VBoxContainer/HBoxContainer/Fps
@onready var ping_label : Label = $MarginContainer/VBoxContainer/HBoxContainer2/Ping
@onready var player_list_container: VBoxContainer = $MarginContainer2/VBoxContainer/PlayerContainer

var gui_player_list = {}

func _ready():
	Server.pinged.connect(update_ping)
#	Server.ui_add_player.connect(add_player)
	Server.ui_update_player.connect(update_player_list)

func update_ping(ping : float):
	ping_label.text = str((int)(ping * 1000))
	fps_label.text = str(Engine.get_frames_per_second())

func add_player(name: String):
	var player_label = Label.new()
	player_label.text =name
	player_list_container.add_child(player_label)
	gui_player_list[name] = player_label

func remove_player(name: String):
	gui_player_list[name].queue_free()
	gui_player_list.erase(name)

func update_player_list(values: Dictionary): # Right now nothing, but later this can be used to populate array with Score/health values.
	for key in gui_player_list.keys(): # clean dewspawned/disconnected players.
		if key not in values.keys(): # if player in gui but not in new list (meaning disconnected)
			remove_player(key)
			
	for key in values.keys(): # add new players to gui
		if key not in gui_player_list: # if player not in gui dictionary
			add_player(key)
