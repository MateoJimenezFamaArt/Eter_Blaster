extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var animation_player = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals = $Visuals


const JUMP_VELOCITY = 4.5

var SPEED = 3
var walk_speed = 3.0
var running_speed = 5.0
var Acceleration = 10.0
var Deceleration = 15.0
var target_speed = 0
#Flags
var is_running = false
var is_locked = false

@export var sens_horizontal = 0.05
@export var sens_vertical = 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))

func _physics_process(delta):
	
	if !animation_player .is_playing():
		is_locked = false
	
	if Input.is_action_just_pressed("Attack"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_locked = true
	
	if Input.is_action_pressed("run"):
		is_running = true
	else:
		is_running = false
	
	if is_running:
		target_speed = running_speed
	else:
		target_speed = walk_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jump()

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		if !is_locked:
			if is_running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else:
				if animation_player.current_animation != "walk":
					animation_player.play("walking")
			visuals.look_at(position + direction)
		
		velocity.x = move_toward(velocity.x, direction.x * target_speed, Acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * target_speed, Acceleration * delta)
	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")

		velocity.x = move_toward(velocity.x, 0, Deceleration * delta)
		velocity.z = move_toward(velocity.z, 0, Deceleration * delta)
	if !is_locked:
		move_and_slide()
		
func jump():
	velocity.y = JUMP_VELOCITY
