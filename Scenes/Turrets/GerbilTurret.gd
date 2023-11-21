extends Sprite2D

@export var projectile : PackedScene
@export var turret_cooldown : float = 1.0

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var muzzle : Marker2D = $Muzzle
@onready var projectile_parent = get_tree().get_root()


func attack():
	Server.send_attack(muzzle.global_position, global_rotation)
	
	animation_player.play("Firing")
	var projectile_instance : Node2D = projectile.instantiate()
	projectile_instance.position = muzzle.global_position 
	projectile_instance.rotation = global_rotation
	projectile_instance.set_collision_layer(4)
	projectile_instance.set_collision_mask(9)
	get_tree().get_root().add_child(projectile_instance)
		

func remote_attack(position : Vector2, rotation : float):
	animation_player.play("Firing")
	var projectile_instance : RigidBody2D = projectile.instantiate()
	projectile_instance.position = position
	projectile_instance.rotation = rotation
	projectile_parent.add_child(projectile_instance)
