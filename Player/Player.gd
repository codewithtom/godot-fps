extends KinematicBody

export var speed = 10
export var acceleration = 5
export var gravity = 0.98
export var jump_power = 30
export var mouse_sensitivity = 10
export var vertical_fov = 140
export var focus_on_ready = true

onready var head = $Head
onready var camera = $Head/Camera

var velocity = Vector3.ZERO
var mouse_delta = Vector2.ZERO
var camera_x_rotation = 0

func _ready():
	if focus_on_ready:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		# Capture the mouse coordinates
		mouse_delta = event.relative

func _process(delta):
	# Rotate camera
	if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED) and (mouse_delta.length() > 0):
		# Get rotation degrees
		var x_delta = -mouse_delta.x * mouse_sensitivity * delta
		var y_delta = -mouse_delta.y * mouse_sensitivity * delta
		var temp_rot = Vector3.ZERO
		
		# Rotate the camera
		mouse_delta = Vector2()
		head.rotate_y(deg2rad(x_delta))
		camera.rotate_x(deg2rad(y_delta))

		# Clamp to reasonable maximums
		temp_rot = camera.rotation_degrees
		temp_rot.x = clamp(temp_rot.x, -vertical_fov/2, vertical_fov/2)
		camera.rotation_degrees = temp_rot
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("primary_fire"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var head_basis = head.get_global_transform().basis
	
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= head_basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += head_basis.z
	
	if Input.is_action_pressed("move_left"):
		direction -= head_basis.x
	elif Input.is_action_pressed("move_right"):
		direction += head_basis.x
	
	direction = direction.normalized()
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity.y -= gravity
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_power
	
	velocity = move_and_slide(velocity, Vector3.UP)
