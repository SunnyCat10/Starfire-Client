extends Node2D

var player_instance = preload("res://tanks/remote_player.tscn")

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
