extends Node3D
class_name CameraSupport

@export var target: Player


var mouse_sensitivity = 0.005 # Adjust as needed

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)


func _process(delta):
	transform.origin = transform.origin.slerp(target.transform.origin, 2 * delta)
