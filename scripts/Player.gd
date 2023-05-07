extends KinematicBody2D

var is_master = false

var speed


func _ready():
	var tween = $Tween
	tween.interpolate_property(self, "speed", 100, 300, 0.2, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()


func _process(delta):
	if is_master:
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
			$AnimatedSprite.play()
			velocity = velocity.normalized() * speed
		else:
			$AnimatedSprite.stop()

		position += velocity * delta

		rpc_unreliable("set_animation", $AnimatedSprite.animation)
		rpc_unreliable("set_position", position)


func initialize(id):
	is_master = id == AutoLoad.net_id


remote func set_animation(animation):
	$AnimatedSprite.animation = animation


remote func set_position(pos):
	position = pos
