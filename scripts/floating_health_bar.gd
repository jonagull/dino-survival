extends Node2D

@onready var health_bar = $HealthBar
var target: Node2D = null

func _ready():
	# Make sure the health bar is always on top
	z_index = 100
	# Make the health bar slightly transparent when at full health
	modulate.a = 0.8

func setup(entity: Node2D, health_component: Node) -> void:
	target = entity
	health_bar.setup(health_component)

func _process(_delta):
	if target and is_instance_valid(target):
		global_position = target.global_position + Vector2(0, -20)  # Reduced offset
		# Make health bar more visible when health is low
		if health_bar.value < 50:
			modulate.a = 1.0
		else:
			modulate.a = 0.8
	else:
		queue_free()  # Remove if target is gone 
