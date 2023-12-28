extends Node3D

@onready var ball = $RigidBody3D
@onready var cameraSupport = $CameraSupport
@onready var direction_helper = $BallDirection
@onready var ball_vertical_dir:float = 5
@onready var ball_horizontal_dir:float = -5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if (Input.is_action_pressed("ui_up")):
		ball_vertical_dir += 10 * delta
	if (Input.is_action_pressed("ui_down")):
		ball_vertical_dir -= 10 * delta
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	cameraSupport.transform.origin = cameraSupport.transform.origin.slerp(ball.transform.origin, 2 *  delta)
	
	var direction:Vector3 = (cameraSupport.transform.basis * Vector3(0,ball_vertical_dir,ball_horizontal_dir)).normalized() 
	var force: float = 2000 * delta
	
	direction_helper.transform.origin = ball.transform.origin
	direction_helper.look_at(ball.transform.origin + direction, Vector3.UP)
	
	if (Input.is_action_just_pressed("ui_accept")):
		ball.apply_force(direction * force)
	pass
