extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var anim_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@export var speed: float = 40.0
var target: Node2D = null
var attack_range: float = 32.0
var attack_cooldown: float = 1.0
var time_since_attack: float = 0.0
@export var attack_damage: float = 10.0
var is_dead: bool = false
var is_attacking: bool = false

func _ready():
	# Optionally set a target here if needed
	anim_sprite.play('walk')
	add_to_group("enemies")  # Add to enemies group for turret targeting
	health_component.health_depleted.connect(_on_health_depleted)
	print("Enemy spawned: ", name)

func take_damage(amount: float) -> void:
	if health_component and not is_dead:
		print("Enemy taking damage: ", name, " amount: ", amount, " current health: ", health_component.current_health)
		health_component.take_damage(amount)

func _on_health_depleted() -> void:
	if not is_dead:
		print("Enemy starting death sequence: ", name)
		is_dead = true
		# Disable collision and processing
		if collision_shape:
			collision_shape.set_deferred("disabled", true)
		set_process(false)
		set_physics_process(false)
		# Remove from enemies group so turrets stop targeting
		remove_from_group("enemies")
		print("Enemy removed from group: ", name)
		# Play death animation
		anim_sprite.play('death')
		print("Enemy playing death animation: ", name)
		# Wait for animation to finish before removing
		await anim_sprite.animation_finished
		print("Enemy death animation finished, queueing free: ", name)
		queue_free()

func _process(delta):
	if is_dead or is_attacking:
		return
		
	if target and is_instance_valid(target):
		var dist = global_position.distance_to(target.global_position)
		if dist < attack_range:
			time_since_attack += delta
			if time_since_attack >= attack_cooldown:
				time_since_attack = 0.0
				perform_attack()
		else:
			var direction = (target.global_position - global_position).normalized()
			velocity = direction * speed
			move_and_slide()
	else:
		# Target is no longer valid, stop moving
		velocity = Vector2.ZERO
		target = null

func perform_attack():
	if is_attacking or is_dead:
		return
		
	is_attacking = true
	
	# Play attack animation
	anim_sprite.play('attack')
	
	# Wait for attack animation to reach the damage frame
	# You can adjust this timing based on your animation
	await get_tree().create_timer(0.3).timeout  # Adjust timing as needed
	
	# Deal damage
	if target and is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(attack_damage)
	
	# Wait for attack animation to finish
	await anim_sprite.animation_finished
	
	# Return to walking
	is_attacking = false
	if not is_dead:
		anim_sprite.play('walk')
