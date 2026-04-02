# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D

class_name Player

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"

var mouse_captured : bool = true
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var question_text: Label = $PlayerUI_3D/QASubViewport/Control/BG/QuestionText
@onready var answer_line_edit: LineEdit = $PlayerUI_3D/QASubViewport/Control/BG/AnswerLineEdit
@onready var submit_answer_button: Button = $PlayerUI_3D/QASubViewport/Control/BG/SubmitAnswerButton
@onready var player_ui_2d: Control = $PlayerUI_2D
@onready var player_ui_3d: Node3D = $PlayerUI_3D
@onready var interact_ray: RayCast3D = $Head/InteractRay
@onready var question_answer_mesh: MeshInstance3D = $PlayerUI_3D/QuestionAnswerMesh
@onready var qa_static_body: StaticBody3D = $PlayerUI_3D/QuestionAnswerMesh/QAStaticBody
@onready var qa_sub_viewport: SubViewport = $PlayerUI_3D/QASubViewport

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	print("Set multiplayer authority to: ", name.to_int())

func _ready() -> void:
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	if is_multiplayer_authority():
		capture_mouse()
		QuizManager.question_received.connect(show_question)
	else:
		camera_3d.queue_free()
		player_ui_2d.queue_free()
		player_ui_3d.queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if interact_ray.is_colliding():
			var ray_collider = interact_ray.get_collider()
			print("Ray is colliding while inputting")
			
			if ray_collider == qa_static_body:
				print("Ray is colliding with QAMesh while inputting")
				var hit_pos = interact_ray.get_collision_point()
				var local_pos = ray_collider.to_local(hit_pos)
				var mesh_scale = question_answer_mesh.scale
				var uv = Vector2((local_pos.x / mesh_scale.x) + 0.5, (-local_pos.y / mesh_scale.y) + 0.5)
				print("UV: %s" % uv)
				var viewport_size = Vector2(qa_sub_viewport.size)
				var screen_pos = uv * viewport_size
				
				var click_event = InputEventMouseButton.new()
				click_event.position = screen_pos
				click_event.global_position = screen_pos
				click_event.pressed = true
				click_event.button_index = MOUSE_BUTTON_LEFT
				click_event.button_mask = MOUSE_BUTTON_MASK_LEFT
				
				qa_sub_viewport.push_input(click_event)

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
		move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Use velocity to actually move
	move_and_slide()


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)
	
	# Body rotates aswell, but only if the player can move; important for 3D UI
	if can_move:
		transform.basis = Basis()
		rotate_y(look_rotation.y)
	else:
		head.rotate_y(look_rotation.y)

func set_look_at(target: Vector3):
	var dir = (target - global_transform.origin).normalized()
	
	look_rotation.y = atan2(-dir.x, dir.z)
	look_rotation.x = asin(dir.y)
	
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func show_question(question_data):
	question_text.text = question_data
