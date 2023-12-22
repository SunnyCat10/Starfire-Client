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
		row_reference.append(label) # TODO: This can blow up!
		add_child(label)
	label_references.append(row_reference)


func update_table() -> void:
	for data_pair in order:
		var row_data = data_pair[Pair.ID]
		for column in range(0, columns, 1):
			label_references[data_pair][column].text = row_data[column]


func update_data_value(player_id : int, update_index : int, value : int) -> void:
	if not data.has(player_id): 
		print("Player " + str(player_id) + " was not added to the scoreboard, updating now...")
		add_player(player_id)
	data[player_id][update_index] = value
	update_table()
