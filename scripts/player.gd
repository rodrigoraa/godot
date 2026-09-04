extends CharacterBody2D


enum PlayerState {
	IDLE,
	WALK,
	JUMP,
	DUCK
}


@onready var collision_shape = $CollisionShape2D
@onready var animation = $CollisionShape2D/AnimatedSprite2D


const SPEED = 170.0
const JUMP_FORCE = -350.0

var state = PlayerState.IDLE
var direction = 0
var jumps = 0
var max_jumps = 2


func _ready():
	go_to_idle()


func _physics_process(delta):

	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		PlayerState.IDLE:
			idle_state()

		PlayerState.WALK:
			walk_state()

		PlayerState.JUMP:
			jump_state()

		PlayerState.DUCK:
			duck_state()

	move_and_slide()


func go_to_idle():
	state = PlayerState.IDLE
	animation.play("idle")


func go_to_walk():
	state = PlayerState.WALK
	animation.play("walk")


func go_to_jump():
	state = PlayerState.JUMP
	animation.play("jump")

	jumps += 1
	velocity.y = JUMP_FORCE


func go_to_duck():
	state = PlayerState.DUCK
	animation.play("duck")

	velocity.x = 0

	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 2


func idle_state():

	move()

	if Input.is_action_pressed("duck"):
		go_to_duck()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump()
		return

	if velocity.x != 0:
		go_to_walk()
		return


func walk_state():

	move()

	if Input.is_action_just_pressed("jump"):
		go_to_jump()
		return

	if velocity.x == 0:
		go_to_idle()
		return


func jump_state():

	move()

	if Input.is_action_just_pressed("jump") and jumps < max_jumps:
		go_to_jump()
		return

	if is_on_floor():

		jumps = 0

		if velocity.x == 0:
			go_to_idle()
			return

		go_to_walk()
		return


func duck_state():

	velocity.x = 0

	if Input.is_action_pressed("duck") == false:

		collision_shape.shape.radius = 6
		collision_shape.shape.height = 14
		collision_shape.position.y = 0

		go_to_idle()
		return


func move():

	update_direction()

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


func update_direction():

	direction = Input.get_axis("left", "right")

	if direction < 0:
		animation.flip_h = true

	elif direction > 0:
		animation.flip_h = false
