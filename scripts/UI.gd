extends Control

@onready var power_ui_indicator: ProgressBar = $CanvasLayer/ProgressBar
@onready var player_data = GameData.player_data

var drop: bool = false


func _on_player_accumulation_force_changed(amount: float):
	power_ui_indicator.value = amount
	drop = false


func _process(delta: float):
	power_ui_indicator.max_value = player_data.max_force
	if drop:
		power_ui_indicator.value -= delta * 5 if power_ui_indicator.value > 0.0 else 0.0


func _on_player_accumulation_force_dropped():
	drop = true
