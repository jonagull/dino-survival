extends Node2D

var HUD: Node2D = null

func _ready() -> void:
	# var nodes = get_tree().get_nodes_in_group("HUD")[0]
	HUD = get_tree().get_nodes_in_group("HUD")[0]
	print(HUD)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if HUD:
			HUD.toggle_interact_text()
			print("tried")
		print("got him!")
	pass

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if HUD:
			HUD.toggle_interact_text()
			print("tried")
		print("got him!")
	pass
