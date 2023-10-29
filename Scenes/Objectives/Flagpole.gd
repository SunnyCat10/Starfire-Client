extends Area2D

@export var team_id : int

@onready var flag : Sprite2D = get_node("%Flag")

var ally_flag_texture : Texture2D = preload("res://assets/Environment/Objectives/ally_team_flag.png")
var enemy_flag_texture : Texture2D = preload("res://assets/Environment/Objectives/enemy_team_flag.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup_flag(client_team_id : int):
	if (client_team_id == team_id):
		flag.texture = ally_flag_texture
	else:
		flag.texture = enemy_flag_texture
	
