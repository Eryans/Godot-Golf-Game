extends Area3D

signal player_entered_zone

func _on_body_entered(body:Node3D):
	if body.name == "Player":
		player_entered_zone.emit()
