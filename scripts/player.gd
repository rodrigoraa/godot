extends CharacterBody2D

const SPEED = 80.0
const JUMP_VELOCITY = -300.0

@onready var sprite: AnimatedSprite2D = $CollisionShape2D/AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimento horizontal
	var direction := Input.get_axis("move_left", "move_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animações
	if not is_on_floor():
		sprite.play("jump")

	elif direction > 0:
		sprite.flip_h = false
		sprite.play("walk")

	elif direction < 0:
		sprite.flip_h = true
		sprite.play("walk")

	else:
		sprite.play("idle")

	move_and_slide()
