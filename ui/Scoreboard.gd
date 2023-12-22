extends Control

@onready var ally_scoreboard = %TeamScoreboard
@onready var enemy_scoreboard = %EnemyScoreboard

func _ready():
	visible = false
	unit_test()


func _process(delta):
	if Input.is_action_just_pressed("show_scoreboard"):
		visible = true
	if Input.is_action_just_released("show_scoreboard"):
		visible = false


func setup_players(ally_team, enemy_team):
	for player in ally_team:
		ally_scoreboard.add_player(player)
	#for player in enemy_team:
		#enemy_scoreboard.add_player(player)
	
	
func unit_test():
	var ally_team = [1,2,3]
	setup_players(ally_team, [])
