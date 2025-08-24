extends Node2D

@onready var interactText = $Interact

func _ready() -> void:
	interactText.visible = false
	pass # Replace with function body.
	
func toggle_interact_text():
	print("getting called my guy!")
	print(interactText)
	interactText.visible = !interactText.visible
	# interactText.visible = true
	pass
