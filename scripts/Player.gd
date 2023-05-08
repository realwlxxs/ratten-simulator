extends KinematicBody2D

var is_master = false

var speed
var weapon = 0
var is_firing = false

signal bullet_spawned(pos, dir)


func _ready():
	var tween = $Tween
	tween.interpolate_property(self, "speed", 100, 300, 0.2, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()


func _process(delta):
	if is_master:
		$Camera2D.current = true

		var mp = get_global_mouse_position()
		rotation = mp.angle_to_point(position)

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

		$Body.play()

		rpc_unreliable("set_animation", $Body.animation, $Body.frame, $Feet.frame, rotation)
		rpc_unreliable("set_position", position)


func _input(event):
	if event.is_action_pressed("switch"):
		weapon = (weapon + 1) % 3
		if not is_firing:
			match weapon:
				0:
					$Body.animation = "unarmed"
				1:
					$Body.animation = "with_pistol"
				2:
					$Body.animation = "with_uzi"
			$UziTimer.stop()
	if event is InputEventMouseButton:
		is_firing = event.pressed
		if not is_firing:
			match weapon:
				0:
					$Body.animation = "unarmed"
				1:
					$Body.animation = "with_pistol"
				2:
					$Body.animation = "with_uzi"
			$UziTimer.stop()
		else:
			match weapon:
				0:
					$Body.animation = "unarmed"
				1:
					$Body.animation = "shoot_pistol"
				2:
					$Body.animation = "shoot_uzi"
					$UziTimer.start()


func initialize(id):
	is_master = id == AutoLoad.net_id


remote func set_animation(body_animation, body_frame, feet_frame, rot):
	$Body.animation = body_animation
	$Body.frame = body_frame
	$Feet.frame = feet_frame
	rotation = rot


remote func set_position(pos):
	position = pos


remote func spawn_bullet(pos, dir):
	emit_signal("bullet_spawned", pos, dir)


func _on_UziTimer_timeout():
	if is_master:
		var rl = rotation + rand_range(-0.15, 0.15)
		var rr = rotation + rand_range(-0.15, 0.15)
		emit_signal("bullet_spawned", $GunL.global_position, rl)
		emit_signal("bullet_spawned", $GunR.global_position, rr)
		rpc_unreliable("spawn_bullet", $GunL.global_position, rl)
		rpc_unreliable("spawn_bullet", $GunR.global_position, rr)
