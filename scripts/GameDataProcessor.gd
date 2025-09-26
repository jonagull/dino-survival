class_name GameDataProcessor

var InstructionSet = load("res://src/InstructionSet.gd")

var rooms
var currentRoom = null

func _init():
	rooms = loadJsonData("res://data/game1.json")

# Load the game data from the json file.
func loadJsonData(fileName):
	var file = FileAccess.open(fileName, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			return data_received
		else:
			assert(false, "Unexpected data in JSON output")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		assert(false, "JSON Parse Error")

func process_action(action):
	# If the current room is empty then start with the initial room.
	if currentRoom == null:
		currentRoom = 'room1'
		return render_room(rooms[currentRoom])

	# Is direction/action valid?
	if rooms[currentRoom]['exits'].has(action) == false:
		return 'I don\'t understand!' + "\n"

	# is a direction then change the state to the new room.
	if rooms[currentRoom]['exits'][action].has('destination') == true:
		currentRoom = rooms[currentRoom]['exits'][action]['destination']

	# return the text of the new room
	return render_room(rooms[currentRoom])

# Render a given room, including the exits.
func render_room(room):
	var renderedRoom = ''
	renderedRoom += room['intro'] + "\n"

	renderedRoom += "\nPossible exists are:\n"

	for exit in room['exits']:
		renderedRoom += "- " + room['exits'][exit]['description'] + "\n"

	return renderedRoom
