extends CanvasLayer

@onready var progress_bar : ProgressBar = %ProgressBar


func _ready():
	Server.health_filled.connect(fill_health)
	Server.on_damage.connect(render_damage)


# func _physics_process(delta):
	# if not progress_bar.max_value == 0:
	#	render_damage(1)


func fill_health(health : int):
	progress_bar.max_value = health
	progress_bar.value = progress_bar.max_value


func render_damage(damage : int):
	progress_bar.value -= damage
