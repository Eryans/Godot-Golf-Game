extends Node3D

@export var target:RigidBody3D
@export var rotation_force:float = 2.5

func _process(delta):
	
	transform.origin = transform.origin.slerp(target.transform.origin, 2 *  delta)
	
	if (Input.is_action_pressed("ui_left")):
		rotate_y(rotation_force * delta)
	if (Input.is_action_pressed("ui_right")):
		rotate_y(-rotation_force * delta)
	pass
