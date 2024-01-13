extends RigidBody3D
class_name Player

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var player_data = GameData.player_data

@export var accumulation_speed: float = 2.0
@export var max_accumulation_speed: float = 10.0
@export var slow_down_force: float = 2.0
@export var cooldown: float = 1.5
@export var ball_director: BallDirection

var refill_light: bool = true
var material: StandardMaterial3D
var max_emission_strength: float = 5.0  # Define the maximum emission strength
var emission_speed: float = 25.0  # Speed of emission change
var can_shoot: bool = true
var timer: Timer
var direction: Vector3
var accumulation_force: float
var direction_helper: Node3D
var initial_velocity: Vector3 = Vector3.ZERO
var gravity = Vector3(0, -9.81, 0)


signal accumulation_force_changed


func _ready():
	player_data.max_force = max_accumulation_speed
	accumulation_force = max_accumulation_speed / 2
	accumulation_force_changed.emit(accumulation_force)
	if mesh.get_surface_override_material(0) is StandardMaterial3D:
		material = mesh.get_surface_override_material(0) as StandardMaterial3D
	else:
		print("Material is not StandardMaterial3D")
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = cooldown
	timer.one_shot = true
	timer.timeout.connect(on_timer_timeout)

	direction_helper = Node3D.new()
	#Add the direction_helper to ball_director to avoid applying player rotation to the mesh
	ball_director.add_child(direction_helper)
	for i in range(10):
		var sphere: MeshInstance3D = MeshInstance3D.new()
		var sphere_mesh: SphereMesh = SphereMesh.new()
		sphere_mesh.radius = 0.15
		sphere_mesh.height = 0.15
		sphere.mesh = sphere_mesh
		direction_helper.add_child(sphere)


func _process(delta: float) -> void:
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
	# direction = ball_director.global_transform.basis.z.normalized()
	initial_velocity = direction * (accumulation_force) / mass
	if can_shoot:
		direction_helper.visible = true
		# D�finir un pas de temps pour calculer des points le long de la trajectoire pr�vue.
		var time_step = 0.1  # 0.1 seconde entre chaque point

		# D�finir le temps total sur lequel nous voulons projeter la trajectoire.
		var total_time = 2.0  # Projection de 2 secondes dans le futur

		# Boucler sur chaque enfant de `direction_helper`, qui contient nos indicateurs.
		for i in range(direction_helper.get_child_count()):
			# Calculer le moment 't' pour chaque indicateur bas� sur le pas de temps.
			var t = i * time_step

			# Si le moment calcul� d�passe le temps total pour lequel nous voulons calculer la trajectoire,
			# nous arr�tons la boucle avec `break` pour �viter de positionner des indicateurs inutilement.
			if t > total_time:
				break

			# Utiliser `get_position_at_time` pour obtenir la position estim�e de la balle � ce moment.
			var position_at_t = get_position_at_time(t)

			# Trouver l'enfant actuel de `direction_helper` qui repr�sente l'indicateur pour ce point.
			var current_child = direction_helper.get_child(i)
			
			# Mettre � jour la position de cet indicateur pour qu'il corresponde � la position calcul�e.
			current_child.global_transform.origin = position_at_t
			current_child.global_rotation = Vector3.ZERO

		if Input.is_action_pressed("force_up"):
			accumulation_force += accumulation_speed * delta
			if accumulation_force >= player_data.max_force:
				accumulation_force = player_data.max_force
			accumulation_force_changed.emit(accumulation_force)
		elif Input.is_action_pressed("force_down"):
			accumulation_force -= accumulation_speed * delta
			if accumulation_force <= 0:
				accumulation_force = 0
			accumulation_force_changed.emit(accumulation_force)

	else:
		direction_helper.visible = false

	var horizontal_velocity = linear_velocity
	horizontal_velocity.y = 0  # Annule la composante Y pour conserver l'effet de la gravit�

	if Input.is_action_pressed("slow_down") && horizontal_velocity.length() > 0:
		apply_central_impulse(-horizontal_velocity * slow_down_force * delta)
		# V�rifiez si la vitesse horizontale est presque nulle
		if horizontal_velocity.length() < 1:
			horizontal_velocity = Vector3.ZERO
			linear_velocity.x = 0
			linear_velocity.z = 0  # Annule les composantes X et Z, mais conserve la composante Y


func get_position_at_time(time: float) -> Vector3:
	# `displacement` est le d�placement de la balle � partir de son point d'origine.
	# Il se compose de deux parties : le mouvement uniforme et l'acc�l�ration due � la gravit�.

	# `initial_velocity * time` calcule le d�placement d� au mouvement initial uniforme.
	# Cela suppose que la vitesse reste constante (sans tenir compte de la gravit�).
	var displacement = initial_velocity * time

	# `gravity * (0.5 * pow(time, 2))` calcule le d�placement suppl�mentaire d� � la gravit�.
	# Cela suit l'�quation du mouvement uniform�ment acc�l�r� : (1/2) * a * t^2,
	# o� 'a' est l'acc�l�ration (la gravit�, dans ce cas) et 't' est le temps.
	displacement += gravity * (0.5 * pow(time, 2))

	# La position finale � un moment donn� est la position d'origine du `RigidBody3D`
	# plus le d�placement calcul�.
	return global_transform.origin + displacement


func on_timer_timeout() -> void:
	can_shoot = true


func _on_input_event(
	_camera: Node,
	event: InputEvent,
	click_position: Vector3,
	_click_normal: Vector3,
	_shape_idx: int
):
	# D�tection du survol de la souris
	if event is InputEventMouseMotion:
		direction = (global_transform.origin - click_position).normalized()
	# Application de l'impulsion au clic
	if (
		event is InputEventMouseButton
		&& event.button_index == MOUSE_BUTTON_LEFT
		&& event.pressed
		&& can_shoot
	):
		# Calculer la direction de l'impulsion
		# Appliquer l'impulsion
		apply_impulse(-(click_position - global_transform.origin) * (accumulation_force * 2), direction )
		can_shoot = false
		timer.start()
