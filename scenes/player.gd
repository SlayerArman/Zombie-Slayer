extends CharacterBody2D

@export var move_speed: float = 250.0
@export var jump_velocity: float = -420.0

var gravity: float = 980.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var aim_pivot: Node2D = $AimPivot


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := Input.get_axis(
		"ui_left",
        "ui_right"
	)

	velocity.x = direction * move_speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var mouse_position := get_global_mouse_position()

	sprite.flip_h = mouse_position.x < global_position.x
	aim_pivot.look_at(mouse_position)

	move_and_slide()
