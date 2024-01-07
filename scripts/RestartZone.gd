extends Area3D

func _on_body_entered(body:Node3D):
	if body.name == "Player":
		get_tree().reload_current_scene()