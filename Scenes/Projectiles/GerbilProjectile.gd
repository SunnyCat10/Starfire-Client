extends RigidBody2D

@onready var animation_player : AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var timer : Timer = $Timer

@export var speed : float = 200
@export var life_time = 1.0

func _ready():
	body_entered.connect(on_impact)
	apply_central_impulse(Vector2(speed, 0).rotated(global_rotation))
	animation_player.play("Flying")
	timer.timeout.connect(destroy_projectile)
	timer.start(life_time)


func on_impact(body: Node) -> void:
	destroy_projectile()
	

func destroy_projectile():
	set_deferred("freeze", true)
	animation_player.play("Exploding")
	await animation_player.animation_finished
	queue_free()
