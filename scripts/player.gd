extends RigidBody3D
class_name Player

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var ball_vertical_dir: float = 5.0
@onready var ball_horizontal_dir: float = -5.0
@onready var player_data = GameData.player_data

@export var accumulation_speed: float = 2.0
@export var max_accumulation_speed: float = 10.0
@export var slow_down_force: float = 2.0
@export var cooldown: float = 1.5
@export var camera_support: CameraSupport

var refill_light: bool = true
var material: StandardMaterial3D
var max_emission_strength: float = 5.0  # Define the maximum emission strength
var emission_speed: float = 25.0  # Speed of emission change
var can_shoot: bool = true
var timer: Timer
var direction: Vector3
var accumulation_force: float = 0

signal accumulation_force_changed
signal accumulation_force_dropped


func _ready():
	player_data.max_force = max_accumulation_speed
	if mesh.get_surface_override_material(0) is StandardMaterial3D:
		material = mesh.get_surface_override_material(0) as StandardMaterial3D
	else:
		print("Material is not StandardMaterial3D")
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = cooldown
	timer.one_shot = true
	timer.timeout.connect(on_timer_timeout)


func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		ball_vertical_dir += 10 * delta
	elif Input.is_action_pressed("ui_down"):
		ball_vertical_dir -= 10 * delta
	refill_light = can_shoot
	if material:
		var current_emission_strength: float = material.emission_energy_multiplier
		if !refill_light:
			current_emission_strength = min(
				current_emission_strength + emission_speed * delta, max_emission_strength
			)
		else:
			current_emission_strength = max(current_emission_strength - emission_speed * delta, 0.0)
		material.emission_energy_multiplier = current_emission_strength


func _physics_process(delta: float) -> void:
	direction = (
		camera_support.global_transform.basis
		* (
			Vector3(0, clamp(ball_vertical_dir, -2, 15), clamp(ball_horizontal_dir, -5, 5))
			. normalized()
		)
	)

	if can_shoot:
		if Input.is_action_pressed("ui_accept"):
			accumulation_force += accumulation_speed * delta
			if accumulation_force >= player_data.max_force:
				accumulation_force = player_data.max_force
			accumulation_force_changed.emit(accumulation_force)
		if Input.is_action_just_released("ui_accept"):
			accumulation_force_dropped.emit()
			var impulse_strength: float = accumulation_force
			apply_central_impulse(direction * impulse_strength)
			can_shoot = false
			timer.start()
			accumulation_force = 0
	if Input.is_action_pressed("slow_down") && floor(linear_velocity.length()) > 0:
		apply_central_impulse(-linear_velocity * (slow_down_force * delta))


func on_timer_timeout() -> void:
	can_shoot = true
