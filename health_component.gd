extends Node

signal health_changed(current_health: float, max_health: float)
signal health_depleted

@export var max_health: float = 100.0
var current_health: float

func _ready():
	current_health = max_health

func take_damage(amount: float) -> void:
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		health_depleted.emit()

func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func get_health_percentage() -> float:
	return current_health / max_health 
