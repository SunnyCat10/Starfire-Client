extends CanvasLayer


@onready var fps_label : Label = $MarginContainer/VBoxContainer/HBoxContainer/Fps
@onready var ping_label : Label = $MarginContainer/VBoxContainer/HBoxContainer2/Ping


func _ready():
	Server.pinged.connect(update_ping)


func update_ping(ping : float):
	ping_label.text = str((int)(ping * 1000))
	fps_label.text = str(Engine.get_frames_per_second())
