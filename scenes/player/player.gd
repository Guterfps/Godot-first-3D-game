extends CharacterBody3D

@export var speed: float = 14
@export var fall_acceleration: float = 75
@export var jump_impulse: float = 20
@export var bounce_impulse: float = 16

var target_velocity = Vector3.ZERO

signal hit

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_tight"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
	
	apply_ground_velocity(direction)
	apply_vertical_velocity(delta)
	jump()
	bounce()
	
	velocity = target_velocity
	move_and_slide()

func apply_ground_velocity(direction: Vector3) -> void:
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed

func apply_vertical_velocity(delta: float) -> void:
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

func jump() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse

func bounce() -> void:
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		var mob = collision.get_collider()
		
		if (mob != null) and mob.is_in_group("mob") and (Vector3.UP.dot(collision.get_normal()) > 0.1):
			mob.squash()
			target_velocity.y = bounce_impulse
			break

func die() -> void:
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body: Node3D) -> void:
	die()
