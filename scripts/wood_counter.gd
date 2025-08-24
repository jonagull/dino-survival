extends Control

@onready var WoodLabel = $WoodLabel
@onready var StoneLabel = $StoneLabel
@onready var BrushLabel = $StoneLabel

func update_wood(amount: int) -> void:
	WoodLabel.text = "Wood: " + str(amount)
	
func update_stone(amount: int) -> void:
	StoneLabel.text = "Stone: 😌" + str(amount)

func update_brush(amount: int) -> void:
	BrushLabel.text = "Brush: " + str(amount)
