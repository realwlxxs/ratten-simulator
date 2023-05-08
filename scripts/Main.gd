extends Node2D

var player = preload("res://scenes/Player.tscn")
var bullet = preload("res://scenes/Bullet.tscn")


func _ready():
	$Crosshair.play()
	randomize()

	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

	AutoLoad.net_id = get_tree().get_network_unique_id()
	create_player(get_tree().get_network_unique_id())


func create_player(id):
	var a = player.instance()
	a.name = str(id)
	a.position = Vector2(rand_range(-500, 500), rand_range(-300, 300))
	a.initialize(id)
	add_child(a)

	a.connect("bullet_spawned", self, "_on_bullet_spawned")


func _player_connected(id):
	create_player(id)


func _player_disconnected(id):
	get_node(str(id)).queue_free()


func _process(delta):
	$Crosshair.position = get_global_mouse_position()


func _on_bullet_spawned(pos, dir):
	var a = bullet.instance()
	a.position = pos
	a.rotation = dir
	add_child(a)
