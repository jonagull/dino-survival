extends Node2D

@onready var health_component = $HealthComponent
@export var attack_damage: float = 100.0
@export var attack_range: float = 200.0
@export var attack_cooldown: float = 1.0
@export var projectile_scene: PackedScene

var target: Node2D = null
var time_since_last_attack: float = 0.0
var enemies_in_range: Array[Node2D] = []

func _ready():
	health_component.health_depleted.connect(_on_health_depleted)
	# Add area for detection
	var detection_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = attack_range
	collision_shape.shape = shape
	detection_area.add_child(collision_shape)
	add_child(detection_area)
	
	# Connect signals
	detection_area.body_entered.connect(_on_enemy_entered)
	detection_area.body_exited.connect(_on_enemy_exited)

func _process(delta):
	if target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		if distance <= attack_range:
			time_since_last_attack += delta
			if time_since_last_attack >= attack_cooldown:
				time_since_last_attack = 0.0
				print('shoot')
				shoot()
		else:
			# Target is out of range, find a new one
			target = null
	elif enemies_in_range.size() > 0:
		# Find closest enemy in range
		var closest_enemy = null
		var closest_distance = INF
		for enemy in enemies_in_range:
			if is_instance_valid(enemy):
				var distance = global_position.distance_to(enemy.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_enemy = enemy
		target = closest_enemy

func shoot() -> void:
	if not projectile_scene or not target:
		return
		
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.set_target(target.global_position)
	projectile.damage = attack_damage
	get_tree().root.add_child(projectile)

func take_damage(amount: float) -> void:
	health_component.take_damage(amount)

func _on_health_depleted() -> void:
	# Handle turret destruction
	queue_free()

func _on_enemy_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)

func _on_enemy_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		enemies_in_range.erase(body)
		if target == body:
			target = null 
