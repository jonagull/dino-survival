extends Node2D

@onready var hud = $HUD
@onready var player = $Player
@onready var player_health_bar = $HUD/PlayerHealthBar

var build_mode: bool = false
var current_ghost: Node2D = null
var current_turret_scene: PackedScene = null
@export var enemy_scene: PackedScene
@export var floating_health_bar_scene: PackedScene

# Wave system variables
var current_wave: int = 0
var enemies_per_wave: int = 5
var enemies_remaining: int = 0
var wave_delay: float = 5.0
var spawn_delay: float = 1.0
var time_since_last_spawn: float = 0.0
var wave_in_progress: bool = false

# Spawn points
var spawn_points: Array[Vector2] = [
	Vector2(100, 100),
	Vector2(100, 300),
	Vector2(100, 500)
]

func _ready():
	if not hud:
		print('hud not found')
		return
	# Connect HUD signals
	print('connecting hud signals')
	hud.stone_turret_selected.connect(enter_build_mode)
	hud.wood_turret_selected.connect(_on_wood_turret_selected)
	
	# Setup player health bar
	if player and player_health_bar:
		player_health_bar.setup(player.get_node("HealthComponent"))
	
	# Start first wave after a delay
	await get_tree().create_timer(wave_delay).timeout
	start_wave()

func start_wave():
	current_wave += 1
	enemies_remaining = enemies_per_wave + (current_wave - 1) * 2  # Increase enemies per wave
	wave_in_progress = true
	print("Starting wave ", current_wave, " with ", enemies_remaining, " enemies")

func spawn_enemy():
	if enemies_remaining <= 0:
		wave_in_progress = false
		# Start next wave after delay
		await get_tree().create_timer(wave_delay).timeout
		start_wave()
		return
		
	var enemy = enemy_scene.instantiate()
	# Choose random spawn point
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	enemy.global_position = spawn_point
	enemy.target = player
	add_child(enemy)
	
	# Add health bar to enemy
	var health_bar = floating_health_bar_scene.instantiate()
	add_child(health_bar)
	health_bar.setup(enemy, enemy.get_node("HealthComponent"))
	
	enemies_remaining -= 1

func _process(delta):
	if build_mode and current_ghost:
		var mouse_pos = get_global_mouse_position()
		print(mouse_pos)
		current_ghost.position = snap_to_grid(mouse_pos)
		
	if wave_in_progress:
		time_since_last_spawn += delta
		if time_since_last_spawn >= spawn_delay:
			time_since_last_spawn = 0.0
			spawn_enemy()

func enter_build_mode(turret_scene: PackedScene, ghost_scene: PackedScene):
	print('entering build mode')
	print(turret_scene)
	print(ghost_scene)
	build_mode = true
	current_turret_scene = turret_scene

	if current_ghost:
		current_ghost.queue_free()

	current_ghost = ghost_scene.instantiate()
	add_child(current_ghost)
	
func _unhandled_input(event):
	if build_mode and event is InputEventMouseButton and event.pressed:
		place_turret_at(get_global_mouse_position())

func place_turret_at(pos: Vector2):
	var turret = current_turret_scene.instantiate()
	turret.position = snap_to_grid(pos)
	add_child(turret)
	
	# Add health bar to turret
	var health_bar = floating_health_bar_scene.instantiate()
	add_child(health_bar)
	health_bar.setup(turret, turret.get_node("HealthComponent"))

	current_ghost.queue_free()
	current_ghost = null
	build_mode = false

func snap_to_grid(pos: Vector2, grid_size: int = 32) -> Vector2:
	return Vector2(
		floor(pos.x / grid_size) * grid_size,
		floor(pos.y / grid_size) * grid_size
	)

func _on_wood_turret_selected():
	spawn_enemy()
	# Placeholder for later turret types
	print("Wood turret selected — implement later if needed.")
