extends Node3D

@onready var ball: Player = $Player
@onready var cameraSupport: Node3D = $CameraSupport
@onready var direction_helper: Node3D = $BallDirection
@onready var ball_vertical_dir: float = 5.0
@onready var ball_horizontal_dir: float = -5.0

@export var force: float = 15.0
@export var cooldown: float = 1.5

var can_shoot: bool = true
var timer: Timer

func _ready():
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

func _physics_process(delta: float) -> void:
	ball.refill_light = can_shoot
	var direction: Vector3 = (cameraSupport.global_transform.basis * Vector3(0, ball_vertical_dir, ball_horizontal_dir)).normalized()
	
	direction_helper.global_transform.origin = ball.global_transform.origin
	direction_helper.look_at(ball.global_transform.origin + direction, Vector3.UP)
	
	if can_shoot:
		if Input.is_action_just_pressed("ui_accept"):
			var impulse_strength: float = force * delta 
			ball.apply_central_impulse(direction * impulse_strength)
			can_shoot = false
			timer.start()


func on_timer_timeout() -> void:
	can_shoot = true
