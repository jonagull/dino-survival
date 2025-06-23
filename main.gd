extends Node2D

@onready var hud = $HUD
@onready var build_menu = $HUD/Panel/BuildMenu
@onready var player = $Player
@onready var player_health_bar = $HUD/PlayerHealthBar
@onready var materials_counter = $HUD/MaterialsCounter
# @onready var stone_counter = $HUD/StoneCounter

var build_mode: bool = false
var current_ghost: Node2D = null
var current_turret_scene: PackedScene = null
@export var enemy_scene: PackedScene
@export var floating_health_bar_scene: PackedScene
@export var spawn_enemies: bool = true
@export var stone_turret_scene: PackedScene
@export var stone_turret_ghost_scene: PackedScene
@export var wood_turret_scene: PackedScene
@export var wood_turret_ghost_scene: PackedScene

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
	if hud and player:
		#hud.connect_player_wood_signal(player)
		# Connect wood counter directly
		player.wood_changed.connect(materials_counter.update_wood)
		player.stone_changed.connect(materials_counter.update_stone)
		player.wood_changed.connect(hud.update_build_menu)
		player.stone_changed.connect(hud.update_build_menu)

	if not hud:
		return
	# Connect HUD signals
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
	if not spawn_enemies:
		return


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
	
	# Only set target if player is valid
	if player and is_instance_valid(player):
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

func _input(event):
	# Handle keyboard turret selection even when build menu is closed
	if event.is_action_pressed("select_turret_1"):
		# Wood turret - you'll need to implement this
		print("Keyboard selected: Wood Turret")
		# enter_build_mode(wood_turret_scene, wood_turret_ghost_scene)
	elif event.is_action_pressed("select_turret_2"):
		# Stone turret
		print("Keyboard selected: Stone Turret")
		enter_build_mode(stone_turret_scene, stone_turret_ghost_scene)
