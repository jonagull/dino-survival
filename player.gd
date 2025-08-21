extends CharacterBody2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var health_component = $HealthComponent
@onready var tree_detection = $TreeDetectionArea
@onready var stone_detection = $StoneDetectionArea
@onready var hud = get_node("/root/Main/HUD")
@export var speed := 100

var last_direction := "down"

var wood: int = 0
var stone: int = 0
var brush: int = 0

var current_tree: Node2D = null
var current_stone: Node2D = null
var chop_cooldown: float = 0.5
var current_brush: Node2D = null
var time_since_last_chop: float = 0.0
var time_since_last_mine: float = 0.0
var is_chopping: bool = false
var is_mining: bool = false

signal wood_changed(amount: int)
signal stone_changed(amount: int)

func set_brush(brush_node):
	current_brush = brush_node
	
func clear_brush():
	current_brush = null


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Connect health signals
	health_component.health_depleted.connect(_on_health_depleted)
	# Connect tree detection signals
	tree_detection.body_entered.connect(_on_tree_detection_area_body_entered)
	tree_detection.body_exited.connect(_on_tree_detection_area_body_exited)
	stone_detection.body_entered.connect(_on_stone_detection_area_body_entered)
	stone_detection.body_exited.connect(_on_stone_detection_area_body_exited)

func _physics_process(_delta):
	if is_chopping or is_mining:
		return
		
	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	)
	
	#current_brush.chop()

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
	
func _unhandled_input(event):
	# Check for left mouse click or E key press
	var should_interact = false
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		should_interact = true
	elif event is InputEventKey and event.pressed and event.keycode == KEY_E:
		should_interact = true
	
	if should_interact:
		#Brush interaction
		if current_brush:
			current_brush.chop()
			print("ojsadfhalkjshflakjshdf")
			anim_sprite.animation = "chop_" + last_direction
			anim_sprite.play()

		# Tree interaction
		if current_tree:
			if not is_chopping:
				start_chopping()
			else:
				stop_chopping()

		# Stone interaction
		if current_stone:
			if not is_mining:
				start_mining()
			else:
				stop_mining()

func _process(delta):
	if is_chopping and current_tree:
		time_since_last_chop += delta
		if time_since_last_chop >= chop_cooldown:
			time_since_last_chop = 0.0
			current_tree.take_damage(current_tree.chop_damage)
			# Play chop animation
			anim_sprite.animation = "chop_" + last_direction
			anim_sprite.play()

	if is_mining and current_stone:
		time_since_last_mine += delta
		if time_since_last_mine >= chop_cooldown:
			time_since_last_mine = 0.0
			current_stone.take_damage(current_stone.chop_damage)
			# Play mining animation
			anim_sprite.animation = "chop_" + last_direction
			anim_sprite.play()

func start_chopping() -> void:
	if current_tree:
		is_chopping = true
		current_tree.start_chopping(self)

func stop_chopping() -> void:
	is_chopping = false
	time_since_last_chop = 0.0
	if current_tree:
		current_tree.stop_chopping()

func start_mining() -> void:
	if current_stone:
		print("mining")
		is_mining = true
		current_stone.start_mining(self)

func stop_mining() -> void:
	is_mining = false
	time_since_last_mine = 0.0
	if current_stone:
		current_stone.stop_mining()

func take_damage(amount: float) -> void:
	health_component.take_damage(amount)

func _on_health_depleted() -> void:
	queue_free()

func add_wood(amount: int) -> void:
	wood += amount
	wood_changed.emit(wood) # Emit signal for UI update

func add_brush(amount: int) -> void:
	brush += amount

	# wood_changed.emit(wood) # Emit signal for UI update

func add_stone(amount: int) -> void:
	stone += amount
	stone_changed.emit(stone) # Emit signal for UI update

func _on_tree_detection_area_body_entered(body: Node2D):
	if body.is_in_group("trees"):
		current_tree = body
		if hud:
			hud.show_interaction_tip("Press E to chop")

func _on_tree_detection_area_body_exited(body: Node2D):
	if body == current_tree:
		stop_chopping()
		current_tree = null
		if hud:
			hud.hide_interaction_tip()

func _on_stone_detection_area_body_entered(body: Node2D):
	if body.is_in_group("stones"):
		current_stone = body
		if hud:
			hud.show_interaction_tip("Press E to mine")

func _on_stone_detection_area_body_exited(body: Node2D):
	if body == current_stone:
		stop_mining()
		current_stone = null
		if hud:
			hud.hide_interaction_tip()
