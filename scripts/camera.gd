extends Node3D
class_name CameraSupport

@export var target: Node3D

@onready var spring_arm: SpringArm3D = $SpringArm3D

var rot_x = 0.0
var rot_y = 0.0
var mouse_sensitivity = 0.0025 # Adjust as needed

var zoom_step: float = 2.0
var zoom_speed: float = 5.0
var target_zoom_length: float
var is_mouse_button_pressed = false
var click_start_time = 0.0
var click_threshold = 0.2  # Time in seconds to distinguish a click from a hold

func _ready():
	target_zoom_length = spring_arm.spring_length

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				click_start_time = Time.get_ticks_msec() / 1000.0
				is_mouse_button_pressed = false
			else:
				var click_duration = Time.get_ticks_msec() / 1000.0 - click_start_time
				if click_duration < click_threshold and not is_mouse_button_pressed:
					# Handle as a simple click
					_handle_single_click()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				is_mouse_button_pressed = false

	if event is InputEventMouseMotion:
		if is_mouse_button_pressed:
			# Camera rotation with mouse
			rot_x += event.relative.x * mouse_sensitivity
			rot_y -= event.relative.y * mouse_sensitivity  # Invert Y axis if necessary

			# Limit vertical rotation
			var max_vertical_angle = deg_to_rad(30.0)
			var min_vertical_angle = deg_to_rad(-30.0)
			rot_y = clamp(rot_y, min_vertical_angle, max_vertical_angle)

			# Apply rotation
			transform.basis = Basis()  # Reset rotation
			rotate_object_local(Vector3.UP, rot_x)  # Y rotation
			rotate_object_local(Vector3.RIGHT, rot_y)  # X rotation
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var time_held = Time.get_ticks_msec() / 1000.0 - click_start_time
			if time_held >= click_threshold and not is_mouse_button_pressed:
				is_mouse_button_pressed = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _handle_single_click():
	pass

func _process(delta):
	# Follow the target smoothly
	transform.origin = transform.origin.lerp(target.transform.origin, 2 * delta)

	# Mouse wheel zoom
	if Input.is_action_just_pressed("scroll_up"):
		target_zoom_length -= zoom_step
	if Input.is_action_just_pressed("scroll_down"):
		target_zoom_length += zoom_step

	# Smoothly interpolate to the target zoom length
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom_length, zoom_speed * delta)
	spring_arm.spring_length = clamp(spring_arm.spring_length, 2.0, 20.0)
