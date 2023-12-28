extends Node3D

@onready var ball = $RigidBody3D
@onready var cameraSupport = $SpringArm3D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	cameraSupport.transform.origin = cameraSupport.transform.origin.slerp(ball.transform.origin, 1.5 *  delta)
	
	var force: float = 1000 * delta
	if (Input.is_action_just_pressed("ui_accept")):
		ball.apply_force((cameraSupport.transform.basis * Vector3(0,25,1)) * force)
	pass
