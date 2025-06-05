extends ProgressBar

@onready var fill = $Fill
var health_component: Node = null

func _ready():
	value = 100
	hide()

func setup(component: Node) -> void:
	health_component = component
	health_component.health_changed.connect(_on_health_changed)
	show()
	_on_health_changed(health_component.current_health, health_component.max_health)

func _on_health_changed(current: float, maximum: float) -> void:
	value = (current / maximum) * 100
	
	# Change color based on health percentage
	var health_percent = current / maximum
	if health_percent > 0.6:
		fill.color = Color(0.2, 0.8, 0.2)  # Green
	elif health_percent > 0.3:
		fill.color = Color(0.8, 0.8, 0.2)  # Yellow
	else:
		fill.color = Color(0.8, 0.2, 0.2)  # Red 
