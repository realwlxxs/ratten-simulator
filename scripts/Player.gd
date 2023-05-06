extends KinematicBody2D

export var speed = 400


func _ready():
	pass


func _process(delta):
	var velocity = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		$AnimatedSprite.animation = "right"
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		$AnimatedSprite.animation = "left"
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		$AnimatedSprite.animation = "down"
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		$AnimatedSprite.animation = "up"
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	position += velocity * delta
