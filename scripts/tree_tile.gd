extends Node2D

@export var wood_amount: int = 3
@export var chop_damage: float = 10.0
@export var max_health: float = 100.0

var current_health: float
var is_chopping: bool = false
var chopper: Node2D = null

func _ready():
	current_health = max_health
	add_to_group("trees")

func take_damage(amount: float) -> void:
	if not is_chopping:
		return
		
	current_health -= amount
	# You could add a visual effect here
	
	if current_health <= 0:
		_on_health_depleted()

func _on_health_depleted() -> void:
	if chopper and chopper.has_method("add_wood"):
		chopper.add_wood(wood_amount)
	queue_free()

func start_chopping(player: Node2D) -> void:
	is_chopping = true
	chopper = player

func stop_chopping() -> void:
	is_chopping = false
	chopper = null 
