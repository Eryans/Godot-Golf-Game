extends Node3D
class_name CameraSupport

@export var target: Player

var rot_x = 0
var rot_y = 0
var mouse_sensitivity = 0.0025 # Adjust as needed

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		# modify accumulated mouse rotation
		rot_x += event.relative.x * mouse_sensitivity
		rot_y += event.relative.y * mouse_sensitivity
		
		var max_vertical_angle = deg_to_rad(30)  # Angle maximum en radians, exemple 45 degrés
		var min_vertical_angle = deg_to_rad(-30) # Angle minimum en radians, exemple -45 degrés
		rot_y = clamp(rot_y, min_vertical_angle, max_vertical_angle)
		
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X


func _process(delta):
	transform.origin = transform.origin.slerp(target.transform.origin, 2 * delta)
