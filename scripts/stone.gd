extends StaticBody2D

@onready var health_component = $HealthComponent
@onready var anim_sprite = $AnimatedSprite2D
# @onready var chop_particles = $ChopParticles
# @onready var fall_particles = $FallParticles
# @onready var chop_sound = $ChopSound
# @onready var fall_sound = $FallSound

@export var stone_amount: int = 5  # Amount of wood you get from mining
@export var chop_damage: float = 1.0
@export var chop_cooldown: float = 0.5

var is_mining: bool = false
var chopper: Node2D = null
var time_since_last_chop: float = 0.0
var current_player: Node2D = null

func _ready():
	health_component.max_health = 5  # Set max health to 5
	health_component.current_health = 5  # Set current health to 5
	health_component.health_depleted.connect(_on_health_depleted)
	add_to_group("stones")
	# Randomize stone appearance slightly
	scale = Vector2(randf_range(0.9, 1.1), randf_range(0.9, 1.1))
	rotation = randf_range(-0.1, 0.1)

func take_damage(amount: float) -> void:
	if health_component and is_mining:  # Changed to check if IS mining
		health_component.take_damage(amount)
		# Visual feedback
		modulate = Color(1.2, 1.2, 1.2)  # Flash white
		# await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1)
		
		# Play chop particles
		# if chop_particles:
		# 	chop_particles.emitting = true
		
		# Play chop sound
		# if chop_sound:
			# chop_sound.play()
	else:
		pass

func _on_health_depleted() -> void:
	#fall_particles.emitting = true
	#fall_sound.play()
	
	if current_player:
		current_player.add_stone(stone_amount)
	else:
		pass
	
	# Wait for particles and sound to finish before removing
	# await get_tree().create_timer(1.0).timeout
	queue_free()

func start_mining(player: Node2D) -> void:
	is_mining = true
	# chopper = player
	# Maybe add a visual indicator that tree can be chopped
	modulate = Color(1.2, 1.2, 1.2)
	current_player = player

func stop_mining() -> void:
	is_mining = false
	# chopper = null
	# Reset visual indicator
	modulate = Color(1, 1, 1)
	current_player = null 
