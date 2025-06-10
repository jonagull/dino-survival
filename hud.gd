extends CanvasLayer

@export var stone_turret_scene: PackedScene
@export var stone_turret_ghost_scene: PackedScene

@onready var build_menu = $Panel/BuildMenu
@onready var build_button = $Panel/BuildButton

signal stone_turret_selected(scene: PackedScene, ghost_scene: PackedScene)
signal wood_turret_selected()

func _ready():
	$Panel/BuildButton.pressed.connect(toggle_build_menu)
	$Panel/BuildMenu/WoodTurretButton.pressed.connect(_on_wood_turret_selected)
	$Panel/BuildMenu/StoneTurretButton.pressed.connect(_on_stone_turret_selected)
	$Panel/BuildMenu/WoodTurretButton.disabled = true
	$Panel/BuildMenu/StoneTurretButton.disabled = true
	$Panel/BuildMenu/StoneTurretButton.tooltip_text = "Requires 20 wood"
		
func update_build_menu(amount: int) -> void:
	if amount >= 10:
		$Panel/BuildMenu/WoodTurretButton.disabled = false
		$Panel/BuildMenu/StoneTurretButton.disabled = false
	elif amount > 20:
		$Panel/BuildMenu/WoodTurretButton.disabled = false
		$Panel/BuildMenu/StoneTurretButton.disabled = true
	else:
		$Panel/BuildMenu/WoodTurretButton.disabled = true

func toggle_build_menu():
	build_menu.visible = not build_menu.visible
	build_button.visible = not build_button.visible

func _on_wood_turret_selected():
	print("Selected: Wood Turret")
	# build_menu.visible = false
	wood_turret_selected.emit()

func _on_stone_turret_selected():
	print("Selected: Stone Turret")
	# build_menu.visible = false
	stone_turret_selected.emit(stone_turret_scene, stone_turret_ghost_scene)
