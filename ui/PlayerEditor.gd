extends Control

@export var option_button_minimum_size : float = 96.
@export var hull_resources : Array[Hull]
@export var turret_resources : Array[UiButtonResource]
@export var coat_resources : Array[UiButtonResource]


@onready var camo_00 : Texture2D = preload("res://assets/Tanks/Paint/Camo_00.png")
@onready var camo_01 : Texture2D = preload("res://assets/Tanks/Paint/Camo_01.png")

@onready var color_picker : ColorPicker = %ColorPicker

#@onready var material_1_btn : TextureButton = %Material1Btn
#@onready var material_2_btn : TextureButton = %Material2Btn

@onready var color_1_btn : TextureButton = %Color1Btn
@onready var color_2_btn : TextureButton = %Color2Btn
@onready var color_3_btn : TextureButton = %Color3Btn

@onready var hull_btn : TextureButton = %HullBtn
@onready var turret_btn : TextureButton = %TurretBtn
@onready var coat_btn : TextureButton = %CoatBtn
@onready var back_btn : TextureButton = %BackBtn
@onready var save_btn : TextureButton = %SaveBtn

@onready var preview : Sprite2D = %Preview

@onready var hull_grid : GridContainer = %HullGrid
@onready var turret_grid : GridContainer = %TurretGrid
@onready var coat_grid : GridContainer = %CoatGrid
@onready var hull_container : ScrollContainer = %HullContainer
@onready var turret_container : ScrollContainer = %TurretContainer
@onready var coat_container : ScrollContainer = %CoatContainer
@onready var coat_data : MarginContainer = %CoatData

var selected_button : int = 1

func _ready():
	color_picker.color_changed.connect(on_color_changed)
	color_1_btn.pressed.connect(func(): selected_button = 1)
	color_2_btn.pressed.connect(func(): selected_button = 2)
	color_3_btn.pressed.connect(func(): selected_button = 3)
	#material_1_btn.pressed.connect(func(): preview.material.set_shader_parameter("selected_texture", camo_00))
	#material_2_btn.pressed.connect(func(): preview.material.set_shader_parameter("selected_texture", camo_01))
	
	hull_btn.pressed.connect(func():
		hide_categories()
		hull_container.visible = true)
	
	turret_btn.pressed.connect(func():
		hide_categories()
		turret_container.visible = true)
	
	coat_btn.pressed.connect(func():
		hide_categories()
		coat_container.visible = true
		coat_data.visible = true)
	
	back_btn.pressed.connect(back_button)
	save_btn.pressed.connect(save_button)
	
	load_categories()
	hide_categories()

func hide_categories() -> void:
	hull_container.visible = false
	turret_container.visible = false
	coat_container.visible = false
	coat_data.visible = false

func back_button() -> void:
	visible = false


func save_button() -> void:
	visible = false


func load_category(category_resources, category_grid : GridContainer) -> void:
	for resource in category_resources :
		var button : TextureButton = resource.load_as_button()
		button.custom_minimum_size = Vector2(option_button_minimum_size, option_button_minimum_size)
		category_grid.add_child(button)


func load_categories() -> void:
	load_category(hull_resources, hull_grid)
	load_category(turret_resources, turret_grid)
	load_category(coat_resources, coat_grid)
	pass

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
