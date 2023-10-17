extends Node2D

var player_instance = preload("res://tanks/remote_player.tscn")
var last_world_state = 0
const interpolation_offset : float = 0.1
var world_state_buffer = []

func spawn_new_player(player_id : int, _position : Vector2):
	print("spawned new player: ", player_id, " at position: ", _position)
	
	if get_tree().get_multiplayer().get_unique_id() == player_id:
		pass
	else:
		var new_player : Node2D = player_instance.instantiate()
		new_player.position = _position
		new_player.name = str(player_id)
		add_child(new_player)
	
# TODO: Fix the despawn
func despawn_player(player_id: int):
	get_node(str(player_id)).queue_free()
	

func _physics_process(delta):
	var render_time = Time.get_unix_time_from_system() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[1]["T"]:
			world_state_buffer.pop_front()
		var interpolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"])
		for player in world_state_buffer[1].keys():
			if str(player) == "T": #WTF?
				print("WTF: str(player) == T")
				continue
			if player == multiplayer.get_unique_id(): # no need to update our own position
				continue
			if not world_state_buffer[0].has(player): # player logged out
				continue
			if has_node(str(player)):
				var player_node : Node2D = get_node(str(player))
				var past_state = world_state_buffer[0][player]
				var future_state = world_state_buffer[1][player]
				var updated_position = lerp(past_state["P"], future_state["P"], interpolation_factor)
				var updated_rotation = lerp(past_state["R"], future_state["R"], interpolation_factor)
				var updated_turret_rotation = lerp(past_state["r"], future_state["r"], interpolation_factor)
				player_node.move_player(updated_position)
				player_node.rotate_player(updated_rotation)
				player_node.rotate_player_turret(updated_turret_rotation)
			else:
				print("spawning player")
				spawn_new_player(player, world_state_buffer[1]["P"])
 
func update_world_state(world_state):
	last_world_state = world_state["T"] # might be redundant
	world_state_buffer.append(world_state)

#func old_update_world_state(world_state):
#	# Buffer
#	# Interpolation
#	# Extrapolation
#	# Rubber Banding
#	# if world_state["T"] > last_world_state:
#	last_world_state = world_state["T"]
#	world_state.erase("T")
#	world_state.erase(multiplayer.get_unique_id())
#	for player in world_state.keys():
#		if has_node(str(player)):
#			var player_node : Node2D = get_node(str(player))
#			player_node.move_player(world_state[player]["P"])
#			player_node.rotate_player(world_state[player]["R"])
#			player_node.rotate_player_turret(world_state[player]["r"])
#		else:
#			print("spawning player")
#			spawn_new_player(player, world_state[player]["P"])
