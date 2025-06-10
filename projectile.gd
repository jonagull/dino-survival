extends Area2D

@export var speed: float = 300.0
@export var damage: float = 10.0
var target_position: Vector2 = Vector2.ZERO

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)
	# Make sure collision is enabled
	monitoring = true
	monitorable = true

func set_target(pos: Vector2) -> void:
	target_position = pos

func _process(delta):
	if target_position != Vector2.ZERO:
		var direction = (target_position - global_position).normalized()
		position += direction * speed * delta
		
		# Remove projectile if it's close enough to target position
		if global_position.distance_to(target_position) < 5:
			queue_free()
	else:
		queue_free()  # Remove projectile if no target position

func _on_body_entered(body: Node2D):
	print("Projectile hit: ", body.name)  # Debug print
	if body.has_method("take_damage"):
		print("Dealing damage to: ", body.name)  # Debug print
		body.take_damage(damage)
	queue_free()  # Remove projectile after hitting something 
