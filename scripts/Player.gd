extends KinematicBody2D

var is_master = false

var speed
var weapon = 0
var is_firing = false
var health = 100

signal bullet_spawned(pos, dir)


func _ready():
	var tween = $Tween
	tween.interpolate_property(self, "speed", 100, 300, 0.2, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()


func _process(delta):
	if is_master:
		$Box/Label.text = str(health)
		if health < 0:
			$Body.animation = "death"
			rpc_unreliable("set_alive")
			$Feet.hide()
		else:
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
			rpc_unreliable("set_health", health)


func _input(event):
	if event.is_action_pressed("switch"):
		weapon = (weapon + 1) % 3
		if not is_firing and health >= 0:
			match weapon:
				0:
					$Body.animation = "unarmed"
				1:
					$Body.animation = "with_pistol"
				2:
					$Body.animation = "with_uzi"
	if event is InputEventMouseButton:
		is_firing = event.pressed
		if health >= 0:
			if not is_firing:
				match weapon:
					0:
						$Body.animation = "unarmed"
					1:
						$Body.animation = "with_pistol"
					2:
						$Body.animation = "with_uzi"
			else:
				match weapon:
					0:
						$Body.animation = "unarmed"
					1:
						$Body.animation = "shoot_pistol"
						$PistolTimer.start()
					2:
						$Body.animation = "shoot_uzi"
						$UziTimer.start()
	if health < 0 or not is_firing:
		$PistolTimer.stop()
		$UziTimer.stop()

	if event is InputEventMouseMotion:
		var tg = event.position - get_viewport().size / 2
		var static_area = 10
		if tg.length() > static_area:
			$Camera2D.position = tg / 4


func initialize(id):
	is_master = id == AutoLoad.net_id


remote func set_animation(body_animation, body_frame, feet_frame, rot):
	$Body.animation = body_animation
	$Body.frame = body_frame
	$Feet.frame = feet_frame
	rotation = rot


remote func set_position(pos):
	position = pos


remote func set_health(h):
	health = h
	$Box/Label.text = str(health)


remote func set_alive():
	$Feet.visible = health >= 0
	if health < 0:
		$Body.animation = "death"
		$Body.play()


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


var hand = 0


func _on_PistolTimer_timeout():
	if is_master:
		hand = (hand + 1) % 2
		var rl = $GunL.global_position.angle_to_point(get_global_mouse_position()) + PI
		var rr = $GunR.global_position.angle_to_point(get_global_mouse_position()) + PI
		if hand == 0:
			emit_signal("bullet_spawned", $GunL.global_position, rl)
			rpc_unreliable("spawn_bullet", $GunL.global_position, rl)
		else:
			emit_signal("bullet_spawned", $GunR.global_position, rr)
			rpc_unreliable("spawn_bullet", $GunR.global_position, rr)


func _on_HurtBox_area_entered(_area):
	health -= 10
