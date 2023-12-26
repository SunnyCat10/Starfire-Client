extends Sprite2D

@onready var color_picker : ColorPicker = %ColorPicker;


func _ready():
	color_picker.color_changed.connect(on_color_changed);


func on_color_changed(color : Color):
	material.set_shader_parameter("new_color", color);
