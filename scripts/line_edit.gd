extends LineEdit

const TextParser = preload("res://scripts/TextParser.gd")
const GameDataProcessor = preload("res://scripts/GameDataProcessor.gd")
#@onready var gameText: RichTextLabel = $MarginContainer/GameText
#@onready var gameText: RichTextLabel = %GameText
@export var gameText: RichTextLabel

#var gameText: RichTextLabel
var text_parser = null
var game_data_processor = null

# Called when the node enters the scene tree for the first time.
func _ready():
	#gameText = get_parent().get_parent().get_node("GameText")
	text_parser = TextParser.new()
	game_data_processor = GameDataProcessor.new()
	gameText.add_text(game_data_processor.process_action('' + "\n"))
	#gameText.append_text(game_data_processor.process_action('') + "\n")das
	
	# Put the LineEdit in write mode
	self.grab_focus()
	self.editable = true

func _on_text_submitted(new_text):
	if (new_text.is_empty()):
		return

	# clear the text of the text area.
	self.set_text('')

	# parse text
	var instruction = text_parser.parse(new_text)

	# send to game data
	var output_text = ''
	output_text += " > " + new_text + "\n\n"
	output_text += game_data_processor.process_action(instruction)
	output_text += "\n"

	# pass output to the game text area
	gameText.add_text(output_text)
	
	# Force focus back to LineEdit after processing
	# Use multiple attempts to ensure focus is maintained
	await get_tree().process_frame
	self.grab_focus()
	self.editable = true
	
	# Try again after another frame to override any other focus changes
	await get_tree().process_frame
	self.grab_focus()
	
	# One more time to be sure
	call_deferred("grab_focus")
