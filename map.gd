extends Node2D

var player_instance = preload("res://tanks/remote_player.tscn")
var last_world_state = 0

func spawn_new_player(player_id : int, _position : Vector2):
	print("spawned new player: ", player_id, " at position: ", _position)
	
	if get_tree().get_multiplayer().get_unique_id() == player_id:
		pass
	else:
		var new_player : Node2D = player_instance.instantiate()
		new_player.position = _position
		new_player.name = str(player_id)
		add_child(new_player)
	
func despawn_player(player_id: int):
	get_node(str(player_id)).queue_free()

func update_world_state(world_state):
	# Buffer
	# Interpolation
	# Extrapolation
	# Rubber Banding
	# if world_state["T"] > last_world_state:
	last_world_state = world_state["T"]
	world_state.erase("T")
	world_state.erase(multiplayer.get_unique_id())
	for player in world_state.keys():
		if has_node(str(player)):
			var player_node : Node2D = get_node(str(player))
			player_node.move_player(world_state[player]["P"])
			player_node.rotate_player(world_state[player]["R"])
		else:
			print("spawning player")
			spawn_new_player(player, world_state[player]["P"])
