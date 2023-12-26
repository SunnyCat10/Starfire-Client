extends Control

@onready var camo_00 : Texture2D = preload("res://assets/Tanks/Paint/Camo_00.png")
@onready var camo_01 : Texture2D = preload("res://assets/Tanks/Paint/Camo_01.png")

@onready var color_picker : ColorPicker = %ColorPicker

@onready var material_1_btn : TextureButton = %Material1Btn
@onready var material_2_btn : TextureButton = %Material2Btn

@onready var color_1_btn : TextureButton = %Color1Btn
@onready var color_2_btn : TextureButton = %Color2Btn
@onready var color_3_btn : TextureButton = %Color3Btn

@onready var preview : Sprite2D = %Preview


var selected_button : int = 1

func _ready():
	color_picker.color_changed.connect(on_color_changed)
	color_1_btn.pressed.connect(func(): selected_button = 1)
	color_2_btn.pressed.connect(func(): selected_button = 2)
	color_3_btn.pressed.connect(func(): selected_button = 3)
	material_1_btn.pressed.connect(func(): preview.material.set_shader_parameter("selected_texture", camo_00))
	material_2_btn.pressed.connect(func(): preview.material.set_shader_parameter("selected_texture", camo_01))


func on_color_changed(color : Color):
	preview.material.set_shader_parameter("selected_color_" + str(selected_button), color)
	color_button(color)


func color_button(color : Color):
	var button : TextureButton
	match selected_button:
		1:
			button = color_1_btn
		2:
			button = color_2_btn
		3:
			button = color_3_btn
	button.self_modulate = 	color
