extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var anim_sprite = $AnimatedSprite2D
@export var speed: float = 40.0
var target: Node2D = null
var attack_range: float = 32.0
var attack_cooldown: float = 1.0
var time_since_attack: float = 0.0
@export var attack_damage: float = 10.0
var is_dead: bool = false

func _ready():
	# Optionally set a target here if needed
	anim_sprite.play('walk')
	add_to_group("enemies")  # Add to enemies group for turret targeting
	health_component.health_depleted.connect(_on_health_depleted)

func take_damage(amount: float) -> void:
	if health_component and not is_dead:
		health_component.take_damage(amount)

func _on_health_depleted() -> void:
	if not is_dead:
		is_dead = true
		# Play death animation
		anim_sprite.play('death')
		# Wait for animation to finish before removing
		await anim_sprite.animation_finished
		queue_free()

func _process(delta):
	if is_dead:
		return
		
	if target and is_instance_valid(target):
		var dist = global_position.distance_to(target.global_position)
		if dist < attack_range:
			time_since_attack += delta
			if time_since_attack >= attack_cooldown:
				time_since_attack = 0.0
				if target.has_method("take_damage"):
					target.take_damage(attack_damage)
		else:
			var direction = (target.global_position - global_position).normalized()
			velocity = direction * speed
			move_and_slide()
	else:
		# Target is no longer valid, stop moving
		velocity = Vector2.ZERO
		target = null
