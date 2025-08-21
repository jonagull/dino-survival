extends Node2D

@onready var label = $Text

var hp = 3
var current_player = null

func _ready():
	label.visible = false
	print(label.text)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if (area.name == "PlayerArea"):
		label.visible = true
		var player = area.get_parent()
		player.set_brush(self)
		current_player = player
		# area.get_parent().set_brush(self)


func _on_area_2d_area_exited(area: Area2D) -> void:
	if (area.name == "PlayerArea"):
		label.visible = false
		var player = area.get_parent()
		player.clear_brush()
		current_player = null


func chop():
	print("chop")
	hp -= 1
	if hp <= 0:
		current_player.add_brush(1)
		queue_free()
