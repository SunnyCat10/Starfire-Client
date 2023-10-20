extends Node2D

var player_instance = preload("res://tanks/remote_player.tscn")
var last_world_state = 0
const interpolation_offset : float = 0.100
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
	await get_tree().create_timer(0.2).timeout
	get_node(str(player_id)).queue_free()
	

func _physics_process(delta):
	var render_time = Time.get_unix_time_from_system() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2]["T"]:
			world_state_buffer.pop_front()
		if world_state_buffer.size() > 2: # We have a future state
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T": # Stil WTF?
					continue
				if player == multiplayer.get_unique_id(): # no need to update our own position
					continue
				if not world_state_buffer[1].has(player): # player logged out
					continue
				if has_node(str(player)):
					var player_node : Node2D = get_node(str(player))
					var past_state = world_state_buffer[1][player]
					var future_state = world_state_buffer[2][player]
					var updated_position = lerp(past_state["P"], future_state["P"], interpolation_factor)
					var updated_rotation = lerp_angle(past_state["R"], future_state["R"], interpolation_factor)
					var updated_turret_rotation = lerp_angle(past_state["r"], future_state["r"], interpolation_factor)
					player_node.move_player(updated_position)
					player_node.rotate_player(updated_rotation)
					player_node.rotate_player_turret(updated_turret_rotation)
				else:
					print("spawning player")
					spawn_new_player(player, world_state_buffer[2][player]["P"])
		elif render_time > world_state_buffer[1]["T"]: # We have no future world_state
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == multiplayer.get_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					var player_node : Node2D = get_node(str(player))
					player_node.move_player(new_position)
					# add new rotation
					# add new player rotation
			
 
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
