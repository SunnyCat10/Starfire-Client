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
	for player in enemy_team:
		enemy_scoreboard.add_player(player)


func update_player(player_id : int, update_index : int, value : int):
	if ally_scoreboard.is_player_inside(player_id):
		ally_scoreboard.update_data_value(player_id, update_index, value)
	elif enemy_scoreboard.is_player_inside(player_id):
		enemy_scoreboard.update_data_value(player_id, update_index, value)
	
	
func unit_test():
	var ally_team = [1,2,3]
	var enemy_team = [4,5,6]
	setup_players(ally_team, enemy_team)
	update_player(4, 1, 5)
	update_player(2, 3, 6)
	update_player(2, 4, 100)
	update_player(1, 4, 10)
	update_player(3, 4, 12000)
	update_player(6, 1, 21)
	update_player(6, 4, 35000)
