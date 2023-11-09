extends CharacterBody2D

@onready var turret : Node2D = $Turret
@onready var flag_manager : Node2D = $FlagManager
@onready var collision_shape : CollisionShape2D = $CollisionShape2D

var attack_dictionary = {}

func _physics_process(delta) -> void:
	if not attack_dictionary == {}:
		attack()


func move_player(new_position : Vector2) -> void:
	position = new_position


func rotate_player(new_rotation : float) -> void:
	rotation = new_rotation


func rotate_player_turret(new_rotation : float) -> void:
	turret.rotation = new_rotation


func attack() -> void:
	for attack in attack_dictionary.keys():
		# if Server.client_clock >= attack - Server.INTERPOLATION_OFFSET:
			#Server.near_future_changed.emit(name.to_int(), attack_dictionary[attack]["Position"], attack)
			#	print("attacking!!")
		if attack <= Server.client_clock:
			var attack_position : Vector2 = attack_dictionary[attack]["Position"]
			var attack_rotation : float = attack_dictionary[attack]["Rotation"]
			turret.remote_attack(attack_position, attack_rotation)
			attack_dictionary.erase(attack)


func spawn(spawn_position : Vector2) -> void:
	global_position = spawn_position
	rotation = 0
	turret.global_rotation = 0
	collision_shape.set_deferred("disabled", false)
	visible = true


func death() -> void:
	collision_shape.set_deferred("disabled", true)
	visible = false
