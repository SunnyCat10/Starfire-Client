extends GridContainer

@onready var label_theme : Theme = preload("res://ui/theme.tres")

enum Column {NAME, KILLS, ASSISTS, DEATHS, SCORE}
enum Pair {ID, SCORE}

var data = {}
var order = []
var label_references = []


func add_player(player_id : int) -> void:
	var empty_row = [player_id, 0, 0, 0, 0]
	data[player_id] = empty_row
	order.push_back([player_id, 0])
	create_row()
	update_table()


func remove_player() -> void:
	pass


func pair_sort(a, b) -> bool:
	return a[Pair.SCORE] > b[Pair.SCORE]


func create_row() -> void:
	var row_reference = []
	for column in range(0, columns, 1):
		var label : Label = Label.new()
		label.theme = label_theme
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row_reference.push_back(label) # TODO: This can blow up!
		add_child(label)
	label_references.push_back(row_reference)


func update_table() -> void:
	var row_number : int = 0
	print("update")
	for data_pair in order:
		print(data_pair)
		var player_id = data_pair[Pair.ID]
		for column in range(0, columns, 1):
			label_references[row_number][column].text = str(data[player_id][column])
		row_number += 1


func update_data_value(player_id : int, update_index : int, value : int) -> void:
	if not data.has(player_id): 
		print("Player " + str(player_id) + " was not added to the scoreboard, updating now...")
		add_player(player_id)
	data[player_id][update_index] = value
	update_table()
