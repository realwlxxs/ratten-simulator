extends KinematicBody2D

var speed = 1000


func _process(delta):
	position += Vector2(1, 0).rotated(rotation) * speed * delta


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
