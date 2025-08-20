extends Node2D

@onready var label = $Text

func _ready():
	label.visible = false
	print(label.text)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if (area.name == "PlayerArea"):
		label.visible = true
		print("got in")
	pass


func _on_area_2d_area_exited(area: Area2D) -> void:
	if (area.name == "PlayerArea"):
		label.visible = false
		print("got in")
	pass # Replace with function body.
