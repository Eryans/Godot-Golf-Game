extends Node3D
class_name CameraSupport

@export var target: Player

@onready var spring_arm: SpringArm3D = $SpringArm3D

var rot_x = 0
var rot_y = 0
var mouse_sensitivity = 0.0025 # Adjust as needed

var zoom_step: float = 2
var zoom_speed: float = 5
var target_zoom_length: float

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	target_zoom_length = spring_arm.spring_length

func _input(event):
	if event is InputEventMouseMotion:
# region mouse camera rotation
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

# region mouse wheel zoom
	if Input.is_action_just_pressed("scroll_up"):
		target_zoom_length -= zoom_step
	if Input.is_action_just_pressed("scroll_down"):
		target_zoom_length += zoom_step

    # Smoothly interpolate to the target zoom length
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom_length, zoom_speed * delta)
	spring_arm.spring_length = clamp(spring_arm.spring_length,2,20)

