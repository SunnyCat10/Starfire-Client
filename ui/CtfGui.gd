extends CanvasLayer

const STATUS_TIMER_COOLDOWN : float = 3.0

var ally_score : int = 0
var enemy_score : int = 0
var ally_flag_taken : bool = false
var enemy_flag_taken : bool = false
var flicker_time : int = 30
var current_flicker_time : int = flicker_time
var is_displaying_status : bool = false

@export var ally_color : Color
@export var enemy_color : Color
@export var emtpy_color : Color

@onready var ally_score_lbl : Label = get_node("%AllyScore")
@onready var enemy_score_lbl : Label = get_node("%EnemyScore")
@onready var timer : Label = get_node("%Timer")
@onready var ally_flag : ColorRect = get_node("%AllyFlag")
@onready var enemy_flag : ColorRect = get_node("%EnemyFlag")
@onready var update_lbl : Label = %UpdateLabel

var status_timer : Timer
var client_team_id : int


func _ready():
	status_timer = Timer.new()
	status_timer.timeout.connect(clear_status)
	add_child(status_timer)


func _physics_process(delta):
	if (current_flicker_time == 0):
		flicker_flag()
		current_flicker_time = flicker_time
	current_flicker_time = current_flicker_time - 1


func flag_taken(team : Server.Team):
	if team == Server.Team.ALLY_TEAM:
		ally_flag_taken = true
	elif team == Server.Team.ENEMY_TEAM:
		enemy_flag_taken = true
	else:
		print("Error: Team number not available > Flag taken")


func flag_returned(team : Server.Team):
	if team == Server.Team.ALLY_TEAM:
		ally_flag_taken = false
		ally_flag.color = ally_color
	elif team == Server.Team.ENEMY_TEAM:
		enemy_flag_taken = false
		enemy_flag.color = enemy_color
	else:
		print("Error: Team number not available > Flag returned")


func flag_captured(team : Server.Team):
	if team == Server.Team.ALLY_TEAM:
		ally_score_lbl.text = str(ally_score_lbl.text.to_int() + 1)
		enemy_flag_taken = false
		enemy_flag.color = enemy_color
	elif team == Server.Team.ENEMY_TEAM:
		enemy_score_lbl.text = str(enemy_score_lbl.text.to_int() + 1)
		ally_flag_taken = false
		ally_flag.color = ally_color
	else:
		print("Error: Team ", team ," not available > Flag captured")	


func flicker_flag():
	if (ally_flag_taken):
		ally_flag.color = emtpy_color if ally_flag.color == ally_color else ally_color
	if (enemy_flag_taken):
		enemy_flag.color = emtpy_color if enemy_flag.color == enemy_color else enemy_color


func update_time(time : float):
	var seconds : int = fmod(time, 60)
	var minutes : int = fmod(time, 60 * 60) / 60
	var time_passed : String = "%02d : %02d" % [minutes, seconds]
	timer.text = time_passed


#func update_status(status_update):
#	if not status_timer.is_stopped():
#		status_timer.stop()
#	render_status(status_update[Packets.StatusPacket.PLAYER_ID], status_update[Packets.StatusPacket.STATUS], status_update[Packets.StatusPacket.TEAM_ID])


#func render_status(player_id, status, team_id):
#	print("player id: ", player_id, " | status: ", status, " | team_id: ", team_id)
#	var output_status : String
#	var output_status_color : Color
#	match status:
#		Packets.FlagStatus.FLAG_TAKEN:
#			output_status = str(player_id) + " took the flag!"
#			output_status_color = ally_color if not team_id == client_team_id else enemy_color
#		Packets.FlagStatus.FLAG_DROPPED:
#			output_status = str(player_id) + " dropped the flag!"
#			output_status_color = ally_color if team_id == client_team_id else enemy_color
#		Packets.FlagStatus.FLAG_CAPTURED:
#			output_status = str(player_id) + " captured the flag!"
#			output_status_color = ally_color if team_id == client_team_id else enemy_color
#	update_lbl.text = output_status
#	update_lbl.add_theme_color_override("font_color", output_status_color)
#	status_timer.start(STATUS_TIMER_COOLDOWN)


func clear_status():
	status_timer.stop()
	update_lbl.text = ""
	update_lbl.remove_theme_color_override("font_color")
