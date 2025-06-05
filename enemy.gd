extends CharacterBody2D

@export var speed: float = 40.0
var target: Node2D = null
var attack_range: float = 32.0
var attack_cooldown: float = 1.0
var time_since_attack: float = 0.0

func _ready():
	# Optionally set a target here if needed
	$AnimatedSprite2D.play('walk')
	pass

func _process(delta):
	if target:
		var dist = global_position.distance_to(target.global_position)
		if dist < attack_range:
			time_since_attack += delta
			if time_since_attack >= attack_cooldown:
				time_since_attack = 0.0
				print("Enemy attacks!")
				# call damage() on target
		else:
			var direction = (target.global_position - global_position).normalized()
			velocity = direction * speed
			move_and_slide()
