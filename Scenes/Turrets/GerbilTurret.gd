extends Sprite2D

@export var projectile : PackedScene
@export var turret_cooldown : float = 1.0

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var muzzle : Marker2D = $Muzzle


func attack():
		animation_player.play("Firing")
		var projectile_instance : Node2D = projectile.instantiate()
		projectile_instance.position = muzzle.global_position 
		projectile_instance.rotation = global_rotation
		get_tree().get_root().add_child(projectile_instance)
