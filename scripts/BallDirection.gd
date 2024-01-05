extends Node3D
class_name BallDirection

@export var target: Player

const ROTATION_SPEED = 0.05

var rot_x = 0
var rot_y = 0

func _process(delta):
	global_transform.origin = target.global_transform.origin
	# Modifier la rotation accumulée en fonction des touches du clavier
	if Input.is_action_pressed("ui_left"):
		rot_y += ROTATION_SPEED
	if Input.is_action_pressed("ui_right"):
		rot_y -= ROTATION_SPEED
	if Input.is_action_pressed("ui_up"):
		rot_x += ROTATION_SPEED
	if Input.is_action_pressed("ui_down"):
		rot_x -= ROTATION_SPEED

	# Appliquer la rotation
	transform.basis = Basis()  # Réinitialiser la rotation
	rotate_object_local(Vector3(0, 1, 0), rot_y)  # D'abord rotation autour de Y
	rotate_object_local(Vector3(1, 0, 0), rot_x)  # Ensuite rotation autour de X
