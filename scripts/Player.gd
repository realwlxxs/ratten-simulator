extends KinematicBody2D

var is_master = false

var speed


func _ready():
	var tween = $Tween
	tween.interpolate_property(self, "speed", 100, 300, 0.2, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()


func _process(delta):
	if is_master:
		$Camera2D.current = true

		var mp = get_global_mouse_position()
		rotation=mp.angle_to_point(position)

		var velocity = Vector2.ZERO

		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1

		if velocity.length() > 0:
			$Feet.play()
			velocity = velocity.normalized() * speed
		else:
			$Feet.stop()
			$Feet.frame = 2

		position += velocity * delta

		rpc_unreliable("set_animation", $Body.animation, $Body.frame, $Feet.frame,rotation)
		rpc_unreliable("set_position", position)


func initialize(id):
	is_master = id == AutoLoad.net_id


remote func set_animation(body_animation, body_frame,  feet_frame,rot):
	$Body.animation = body_animation
	$Body.frame = body_frame
	$Feet.frame = feet_frame
	rotation = rot


remote func set_position(pos):
	position = pos
