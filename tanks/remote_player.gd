extends CharacterBody2D

@onready var turret : Node2D = $Turret

func move_player(new_position : Vector2):
	position = new_position
	
func rotate_player(new_rotation : float):
	rotation = new_rotation
	
func rotate_player_turret(new_rotation : float):
	turret.rotation = new_rotation
