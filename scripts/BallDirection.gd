extends Node3D
class_name BallDirection

@export var target: Player


func _process(_delta):
	global_transform.origin = target.global_transform.origin
	look_at(target.global_transform.origin + target.direction, Vector3.UP)
