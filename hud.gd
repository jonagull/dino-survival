extends CanvasLayer

@export var stone_turret_scene: PackedScene
@export var stone_turret_ghost_scene: PackedScene

@onready var build_menu = $Panel/BuildMenu
@onready var build_button = $Panel/BuildButton

signal stone_turret_selected(scene: PackedScene, ghost_scene: PackedScene)
signal wood_turret_selected()

# Economy system - turret costs (matching main.gd)
const WOOD_TURRET_COST = {"wood": 15, "stone": 0}
const STONE_TURRET_COST = {"wood": 10, "stone": 20}

func _ready():
	$Panel/BuildButton.pressed.connect(toggle_build_menu)
	$Panel/BuildMenu/WoodTurretButton.pressed.connect(_on_wood_turret_selected)
	$Panel/BuildMenu/StoneTurretButton.pressed.connect(_on_stone_turret_selected)
	$Panel/BuildMenu/WoodTurretButton.disabled = true
	$Panel/BuildMenu/StoneTurretButton.disabled = true
	$Panel/BuildMenu/WoodTurretButton.tooltip_text = "Requires 15 wood"
	$Panel/BuildMenu/StoneTurretButton.tooltip_text = "Requires 10 wood, 20 stone"
		
func update_build_menu(amount: int) -> void:
	# Get current player resources from the main scene
	var main_scene = get_tree().current_scene
	if not main_scene or not main_scene.player:
		return
	
	var player_wood = main_scene.player.wood
	var player_stone = main_scene.player.stone
	
	# Check if player can afford wood turret
	var can_afford_wood_turret = player_wood >= WOOD_TURRET_COST["wood"] and player_stone >= WOOD_TURRET_COST["stone"]
	$Panel/BuildMenu/WoodTurretButton.disabled = not can_afford_wood_turret
	
	# Check if player can afford stone turret
	var can_afford_stone_turret = player_wood >= STONE_TURRET_COST["wood"] and player_stone >= STONE_TURRET_COST["stone"]
	$Panel/BuildMenu/StoneTurretButton.disabled = not can_afford_stone_turret

func toggle_build_menu():
	build_menu.visible = not build_menu.visible
	build_button.visible = not build_button.visible

func _input(event):
	# Handle B key to toggle build menu
	if event.is_action_pressed("open_build_menu"):
		toggle_build_menu()
	
	# Handle number keys for turret selection (only when build menu is open)
	if build_menu.visible:
		if event.is_action_pressed("select_turret_1"):
			_on_wood_turret_selected()
		elif event.is_action_pressed("select_turret_2"):
			_on_stone_turret_selected()

func _on_wood_turret_selected():
	print("Selected: Wood Turret")
	wood_turret_selected.emit()

func _on_stone_turret_selected():
	print("Selected: Stone Turret")
	stone_turret_selected.emit(stone_turret_scene, stone_turret_ghost_scene)
