extends RigidBody3D
class_name  Player

@onready var mesh: MeshInstance3D = $MeshInstance3D
var refill_light: bool = true
var material: StandardMaterial3D
var max_emission_strength: float = 5.0 # Define the maximum emission strength
var emission_speed: float = 25.0 # Speed of emission change

# Called when the node enters the scene tree for the first time.
func _ready():
	if mesh.get_surface_override_material(0) is StandardMaterial3D:
		material = mesh.get_surface_override_material(0) as StandardMaterial3D
	else:
		print("Le matériau n'est pas un StandardMaterial3D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if material:
		var current_emission_strength: float = material.emission_energy_multiplier
		if refill_light:
			# Increase emission strength up to the maximum value
			current_emission_strength = min(current_emission_strength + emission_speed * delta, max_emission_strength)
		else:
			# Decrease emission strength down to zero
			current_emission_strength = max(current_emission_strength - emission_speed * delta, 0.0)
		material.emission_energy_multiplier = current_emission_strength
