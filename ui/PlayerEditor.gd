extends Control

@export var option_button_minimum_size : float = 96.
@export var hull_resources : Array[Hull]
@export var turret_resources : Array[Turret]
@export var coat_resources : Array[UiButtonResource]


#@onready var camo_00 : Texture2D = preload("res://assets/Tanks/Paint/Camo_00.png")
#@onready var camo_01 : Texture2D = preload("res://assets/Tanks/Paint/Camo_01.png")
@onready var editor_color_1 : Texture2D = preload("res://assets/UITextures/EditorColor1.png")
@onready var editor_color_2 : Texture2D = preload("res://assets/UITextures/EditorColor2.png")
@onready var editor_color_3 : Texture2D = preload("res://assets/UITextures/EditorColor3.png")
@onready var editor_color_1_selected : Texture2D = preload("res://assets/UITextures/EditorColor1Selected.png")
@onready var editor_color_2_selected : Texture2D = preload("res://assets/UITextures/EditorColor2Selected.png")
@onready var editor_color_3_selected : Texture2D = preload("res://assets/UITextures/EditorColor3Selected.png")

@onready var color_picker : ColorPicker = %ColorPicker

#@onready var material_1_btn : TextureButton = %Material1Btn
#@onready var material_2_btn : TextureButton = %Material2Btn

#@onready var color_1_btn : TextureButton = %Color1Btn
#@onready var color_2_btn : TextureButton = %Color2Btn
#@onready var color_3_btn : TextureButton = %Color3Btn

@onready var color_buttons : Array[TextureButton] = [%Color1Btn, %Color2Btn, %Color3Btn]

@onready var hull_btn : TextureButton = %HullBtn
@onready var turret_btn : TextureButton = %TurretBtn
@onready var coat_btn : TextureButton = %CoatBtn
@onready var back_btn : TextureButton = %BackBtn
@onready var save_btn : TextureButton = %SaveBtn

# @onready var preview : Sprite2D = %Preview

@onready var hull_grid : GridContainer = %HullGrid
@onready var turret_grid : GridContainer = %TurretGrid
@onready var coat_grid : GridContainer = %CoatGrid
@onready var hull_container : ScrollContainer = %HullContainer
@onready var turret_container : ScrollContainer = %TurretContainer
@onready var coat_container : ScrollContainer = %CoatContainer
@onready var coat_data : MarginContainer = %CoatData

#@onready var tank_hull_preview : TextureRect = %TankHullPreview
@onready var tank_hull_preview : Node2D = %Preview
@onready var tank_turret_preview : Sprite2D = %TankTurretPreview

enum ColorButton {FIRST, SECOND, THIRD}
var selected_button : ColorButton = ColorButton.FIRST

func _ready():
	color_picker.color_changed.connect(on_color_changed)
	
	color_buttons[ColorButton.FIRST].pressed.connect(func(): 
		selected_button = ColorButton.FIRST
		set_button_texture(ColorButton.FIRST)
		color_picker.color = color_buttons[ColorButton.FIRST].self_modulate)
	
	color_buttons[ColorButton.SECOND].pressed.connect(func(): 
		selected_button = ColorButton.SECOND
		set_button_texture(ColorButton.SECOND)
		color_picker.color = color_buttons[ColorButton.SECOND].self_modulate)
	
	color_buttons[ColorButton.THIRD].pressed.connect(func(): 
		selected_button = ColorButton.THIRD
		set_button_texture(ColorButton.THIRD)
		color_picker.color = color_buttons[ColorButton.THIRD].self_modulate)
	
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
	load_turrets(turret_resources, turret_grid)
	load_coats(coat_resources, coat_grid)


func load_turrets(category_resources, category_grid : GridContainer) -> void:
	for resource : UiButtonResource in category_resources :
		var button : TextureButton = resource.load_as_button()
		button.custom_minimum_size = Vector2(option_button_minimum_size, option_button_minimum_size)
		button.pressed.connect(func(): tank_turret_preview.texture = resource.texture)
		category_grid.add_child(button)


func load_coats(category_resources, category_grid : GridContainer) -> void:
	for resource : UiButtonResource in category_resources :
		var button : TextureButton = resource.load_as_button()
		button.custom_minimum_size = Vector2(option_button_minimum_size, option_button_minimum_size)
		button.pressed.connect(func(): tank_hull_preview.material.set_shader_parameter("selected_texture", resource.texture))
		button.pressed.connect(func(): tank_turret_preview.material.set_shader_parameter("selected_texture", resource.texture))
		category_grid.add_child(button)


func on_color_changed(color : Color):
	tank_hull_preview.material.set_shader_parameter("selected_color_" + str(selected_button + 1), color)
	tank_turret_preview.material.set_shader_parameter("selected_color_" + str(selected_button + 1), color)
	color_button(color)


func color_button(color : Color):
	var button : TextureButton
	match selected_button:
		ColorButton.FIRST:
			button = color_buttons[ColorButton.FIRST]
		ColorButton.SECOND:
			button = color_buttons[ColorButton.SECOND]
		ColorButton.THIRD:
			button = color_buttons[ColorButton.THIRD]
	button.self_modulate = 	color


func set_button_texture(currently_selected_button : ColorButton) -> void:
	resest_color_buttons_texture()
	match currently_selected_button:
		ColorButton.FIRST:
			color_buttons[ColorButton.FIRST].texture_normal = editor_color_1_selected
		ColorButton.SECOND:
			color_buttons[ColorButton.SECOND].texture_normal = editor_color_2_selected
		ColorButton.THIRD:
			color_buttons[ColorButton.THIRD].texture_normal = editor_color_3_selected


func resest_color_buttons_texture() -> void:
	color_buttons[ColorButton.FIRST].texture_normal = editor_color_1
	color_buttons[ColorButton.SECOND].texture_normal = editor_color_2
	color_buttons[ColorButton.THIRD].texture_normal = editor_color_3
