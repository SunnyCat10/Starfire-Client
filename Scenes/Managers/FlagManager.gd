extends Node2D

var _flagpole : Node2D
var _client_team_id : int
var with_flag : bool = false

@onready var sprite : Sprite2D = %FlagSprite
@onready var ally_team : Texture2D = preload("res://assets/Drops/ally_team_flag_dropped.png")
@onready var enemy_team : Texture2D = preload("res://assets/Drops/enemy_team_flag_dropped.png")
@onready var flag_drop_scene: PackedScene = preload("res://Scenes/Drops/flag.tscn")


func _physics_process(delta):
	if with_flag == true:
		sprite.global_rotation = 0


func load_flag(flagpole : Node2D, client_team_id : int):
	_flagpole = flagpole
	_client_team_id = client_team_id
	sprite.texture = enemy_team
	with_flag = true


func drop_flag():
	sprite.texture = null
	with_flag = false
	var flag_drop : Node2D = flag_drop_scene.instantiate()
	flag_drop.load_flag(_flagpole, _client_team_id, _flagpole.flag_team_id)
	get_parent().get_parent().add_child(flag_drop)


func capture_flag():
	_flagpole.setup_flag(_client_team_id)
	sprite.texture = null
	with_flag = false

