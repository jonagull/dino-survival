extends Node2D

@onready var hud = $HUD
@onready var build_menu = $HUD/Panel/BuildMenu
@onready var player = $Player
@onready var player_health_bar = $HUD/PlayerHealthBar
@onready var materials_counter = $HUD/MaterialsCounter
# @onready var stone_counter = $HUD/StoneCounter
@onready var music = $AudioStreamPlayer2D

var build_mode: bool = false
var current_ghost: Node2D = null
var current_turret_scene: PackedScene = null
var range_indicator: Node2D = null
@export var enemy_scene: PackedScene
@export var floating_health_bar_scene: PackedScene
@export var spawn_enemies: bool = true
@export var stone_turret_scene: PackedScene
@export var stone_turret_ghost_scene: PackedScene
@export var wood_turret_scene: PackedScene
@export var wood_turret_ghost_scene: PackedScene

# Economy system - turret costs
const WOOD_TURRET_COST = {"wood": 15, "stone": 0}
const STONE_TURRET_COST = {"wood": 10, "stone": 20}

# Placement range system
const MAX_PLACEMENT_DISTANCE = 200.0  # Maximum distance from player to place turrets

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

	music.play()
	
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
		
		# Update ghost appearance based on placement validity
		update_ghost_appearance(mouse_pos)
		
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
	
	# Create range indicator
	create_range_indicator()
	
func create_range_indicator():
	if range_indicator:
		range_indicator.queue_free()
	
	range_indicator = Node2D.new()
	add_child(range_indicator)
	
	# Create a simple circle to show placement range
	var circle = Node2D.new()
	range_indicator.add_child(circle)
	
	# Add a simple visual representation (you can replace this with a proper sprite)
	var draw_node = Node2D.new()
	circle.add_child(draw_node)
	draw_node.draw.connect(_draw_range_circle)
	draw_node.queue_redraw()

func _draw_range_circle():
	if not player:
		return
	
	# Draw a circle around the player to show placement range
	var center = player.global_position - range_indicator.global_position
	draw_arc(center, MAX_PLACEMENT_DISTANCE, 0, 2 * PI, 32, Color(1, 1, 1, 0.3), 2.0)

func _unhandled_input(event):
	if build_mode and event is InputEventMouseButton and event.pressed:
		place_turret_at(get_global_mouse_position())
	elif build_mode and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		exit_build_mode()

func place_turret_at(pos: Vector2):
	# Check if player can afford the turret
	var turret_cost = get_turret_cost(current_turret_scene)
	# if not can_afford_turret(turret_cost):
	# 	print("Not enough resources to build turret!")
	# 	return
	
	# Check if placement is within range
	if not is_placement_in_range(pos):
		print("Cannot place turret too far from player!")
		return
	
	# Spend resources
	spend_resources(turret_cost)
	
	var turret = current_turret_scene.instantiate()
	turret.position = snap_to_grid(pos)
	add_child(turret)
	
	# Add health bar to turret
	var health_bar = floating_health_bar_scene.instantiate()
	add_child(health_bar)
	health_bar.setup(turret, turret.get_node("HealthComponent"))

	exit_build_mode()

func snap_to_grid(pos: Vector2, grid_size: int = 32) -> Vector2:
	return Vector2(
		floor(pos.x / grid_size) * grid_size,
		floor(pos.y / grid_size) * grid_size
	)

func _on_wood_turret_selected():
	enter_build_mode(wood_turret_scene, wood_turret_ghost_scene)
	# Placeholder for later turret types
	print("Wood turret selected — implement later if needed.")

func _input(event):
	# Handle keyboard turret selection even when build menu is closed
	if event.is_action_pressed("select_turret_1"):
		# Wood turret - you'll need to implement this
		print("Keyboard selected: Wood Turret")
		enter_build_mode(wood_turret_scene, wood_turret_ghost_scene)
	elif event.is_action_pressed("select_turret_2"):
		# Stone turret
		print("Keyboard selected: Stone Turret")
		enter_build_mode(stone_turret_scene, stone_turret_ghost_scene)

# Economy system functions
func get_turret_cost(turret_scene: PackedScene) -> Dictionary:
	if turret_scene == stone_turret_scene:
		return STONE_TURRET_COST
	elif turret_scene == wood_turret_scene:
		return WOOD_TURRET_COST
	else:
		return {"wood": 0, "stone": 0}

func can_afford_turret(cost: Dictionary) -> bool:
	if not player:
		return false
	return player.wood >= cost.get("wood", 0) and player.stone >= cost.get("stone", 0)

func spend_resources(cost: Dictionary) -> void:
	if not player:
		return
	
	# Spend wood
	if cost.get("wood", 0) > 0:
		player.wood -= cost["wood"]
		player.wood_changed.emit(player.wood)
	
	# Spend stone
	if cost.get("stone", 0) > 0:
		player.stone -= cost["stone"]
		player.stone_changed.emit(player.stone)

# Placement range system functions
func is_placement_in_range(pos: Vector2) -> bool:
	if not player:
		return false
	
	var distance = player.global_position.distance_to(pos)
	return distance <= MAX_PLACEMENT_DISTANCE

func update_ghost_appearance(mouse_pos: Vector2) -> void:
	if not current_ghost:
		return
	
	var is_valid_placement = is_placement_in_range(mouse_pos)
	
	# Update ghost color based on placement validity
	if current_ghost.has_method("set_valid_placement"):
		current_ghost.set_valid_placement(is_valid_placement)
	else:
		# Fallback: try to modify modulate property
		if is_valid_placement:
			current_ghost.modulate = Color.WHITE
		else:
			current_ghost.modulate = Color.RED

func exit_build_mode():
	if current_ghost:
		current_ghost.queue_free()
		current_ghost = null
	
	if range_indicator:
		range_indicator.queue_free()
		range_indicator = null
	
	build_mode = false
