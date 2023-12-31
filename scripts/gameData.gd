extends Node


class PlayerData:
	var max_force: float = 5.0


var player_data: PlayerData


func _init():
	player_data = PlayerData.new()
