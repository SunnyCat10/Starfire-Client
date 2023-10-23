extends CharacterBody2D

@onready var turret : Node2D = $Turret

var attack_dictionary = {}

func _physics_process(delta):
	if not attack_dictionary == {}:
		attack()

func move_player(new_position : Vector2):
	position = new_position
	
func rotate_player(new_rotation : float):
	rotation = new_rotation
	
func rotate_player_turret(new_rotation : float):
	turret.rotation = new_rotation

func attack():
	for attack in attack_dictionary.keys():
		print("attacking!!")
		if attack <= Server.client_clock:
			# add player_rotation
			position = attack_dictionary[attack]["Position"]
			turret.rotation = attack_dictionary[attack]["Rotation"]
			turret.attack()
			attack_dictionary.erase(attack)
