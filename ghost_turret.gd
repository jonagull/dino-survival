extends Node2D

@onready var sprite = $Sprite2D

var valid_placement_color = Color.WHITE
var invalid_placement_color = Color.RED

func set_valid_placement(is_valid: bool) -> void:
	if sprite:
		if is_valid:
			sprite.modulate = valid_placement_color
		else:
			sprite.modulate = invalid_placement_color 