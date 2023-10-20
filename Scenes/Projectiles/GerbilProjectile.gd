extends Node2D

@onready var animation_player : AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var timer : Timer = $Timer

@export var speed : float = 100.0
@export var life_time = 1.0

func _ready():
	animation_player.play("Flying")
	timer.timeout.connect(destroy_projectile)
	timer.start(life_time)
	

func _physics_process(delta):
	position += transform.x * speed * delta
 

func on_impact(body: Node) -> void:
	destroy_projectile()
	

func destroy_projectile():
	set_physics_process(false)
	animation_player.play("Exploding")
	await animation_player.animation_finished
	queue_free()
