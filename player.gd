extends CharacterBody2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var health_component = $HealthComponent
@export var speed := 100

var last_direction := "down"

func _ready():
	# Connect health signals
	health_component.health_depleted.connect(_on_health_depleted)

func _physics_process(delta):
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if input_vector.length() > 0:
		velocity = input_vector.normalized() * speed
		move_and_slide()

		# Determine direction
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				last_direction = "right"
			else:
				last_direction = "left"
		else:
			if input_vector.y > 0:
				last_direction = "down"
			else:
				last_direction = "up"

		anim_sprite.animation = "walk_" + last_direction
		anim_sprite.play()
	else:
		velocity = Vector2.ZERO
		anim_sprite.animation = "idle_" + last_direction
		anim_sprite.play()

func take_damage(amount: float) -> void:
	health_component.take_damage(amount)

func _on_health_depleted() -> void:
	# Handle player death
	queue_free()
	# You might want to emit a signal here to notify the game manager
	# or show a game over screen
