extends Node2D

@onready var health_component = $HealthComponent
@export var attack_damage: float = 10.0
@export var attack_range: float = 200.0
@export var attack_cooldown: float = 1.0

var target: Node2D = null
var time_since_last_attack: float = 0.0

func _ready():
	health_component.health_depleted.connect(_on_health_depleted)

func _process(delta):
	if target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		if distance <= attack_range:
			time_since_last_attack += delta
			if time_since_last_attack >= attack_cooldown:
				time_since_last_attack = 0.0
				attack()

func attack() -> void:
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)

func take_damage(amount: float) -> void:
	health_component.take_damage(amount)

func _on_health_depleted() -> void:
	# Handle turret destruction
	queue_free() 