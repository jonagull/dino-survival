extends CanvasLayer

@onready var build_menu = $Panel/BuildMenu

func _ready():
	$Panel/BuildButton.pressed.connect(toggle_build_menu)
	$Panel/BuildMenu/WoodTurretButton.pressed.connect(_on_wood_turret_selected)
	$Panel/BuildMenu/StoneTurretButton.pressed.connect(_on_stone_turret_selected)

func toggle_build_menu():
	build_menu.visible = not build_menu.visible

func _on_wood_turret_selected():
	print("Selected: Wood Turret")
	build_menu.visible = false
	# emit signal or call function in Main to enter build mode

func _on_stone_turret_selected():
	print("Selected: Stone Turret")
	build_menu.visible = false
	# emit signal or call function in Main to enter build mode
