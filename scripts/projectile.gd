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
	print("Projectile created")

func set_target(pos: Vector2) -> void:
	target_position = pos

func _process(delta):
	if target_position != Vector2.ZERO:
		var direction = (target_position - global_position).normalized()
		position += direction * speed * delta
		
		# Remove projectile if it's close enough to target position
		if global_position.distance_to(target_position) < 5:
			print("Projectile reached target position, removing")
			queue_free()
	else:
		print("Projectile has no target position, removing")
		queue_free()  # Remove projectile if no target position

func _on_body_entered(body: Node2D):
	if not is_instance_valid(body):
		print("Projectile hit invalid body, removing")
		queue_free()
		return
		
	print("Projectile hit: ", body.name)  # Debug print
	
	# Don't hit the player
	if body.name == "Player":
		print("Projectile hit player, ignoring")
		queue_free()
		return
		
	if body.has_method("take_damage"):
		print("Dealing damage to: ", body.name, " amount: ", damage)  # Debug print
		body.take_damage(damage)
	else:
		print("Cannot deal damage to: ", body.name, " - missing take_damage method")
	queue_free()  # Remove projectile after hitting something 
