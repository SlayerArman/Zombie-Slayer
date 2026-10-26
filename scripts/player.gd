extends CharacterBody2D

@export var afterimage_scene: PackedScene

@export var move_speed: float = 250.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 980.0
@export var max_jumps: int = 2

@export var dash_speed: float = 850.0
@export var dash_duration: float = 0.14
@export var dash_cooldown: float = 0.45

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: float = 1.0
var jumps_left: int = 2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var aim_pivot: Node2D = $AimPivot


func _physics_process(delta: float) -> void:
	
	dash_cooldown_timer = maxf(
		0.0,
		dash_cooldown_timer - delta
	)

	var direction := Input.get_axis("left", "right")
	var mouse_position := get_global_mouse_position()

	sprite.flip_h = mouse_position.x < global_position.x
	aim_pivot.look_at(mouse_position)

	if Input.is_action_just_pressed("dash"):
		if not is_dashing and dash_cooldown_timer <= 0.0:
			start_dash(direction, mouse_position)

	if is_dashing:
		dash_timer -= delta
		velocity = Vector2(dash_direction * dash_speed, 0.0)

		if dash_timer <= 0.0:
			is_dashing = false
			dash_cooldown_timer = dash_cooldown

		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = direction * move_speed

	if is_on_floor():
		jumps_left = max_jumps

	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = jump_velocity
		jumps_left -= 1

	move_and_slide()


func start_dash(direction: float, mouse_position: Vector2) -> void:

	if direction != 0.0:
		dash_direction = signf(direction)
	else:
		var mouse_offset := mouse_position.x - global_position.x

		if mouse_offset != 0.0:
			dash_direction = signf(mouse_offset)
		else:
			dash_direction = -1.0 if sprite.flip_h else 1.0

	is_dashing = true
	dash_timer = dash_duration

func spawn_afterimage() -> void:
	if afterimage_scene == null:
		return

	var ghost = afterimage_scene.instantiate()
	get_parent().add_child(ghost)

	ghost.texture = sprite.sprite_frames.get_frame_texture(
		sprite.animation,
		sprite.frame
	)

	ghost.global_position = sprite.global_position
	ghost.global_rotation = sprite.global_rotation
	ghost.flip_h = sprite.flip_h
	ghost.modulate = Color(0.5, 0.85, 1.0, 0.65)
