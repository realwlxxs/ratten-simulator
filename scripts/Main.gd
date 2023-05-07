extends Node2D

var player = preload("res://scenes/Player.tscn")


func _ready():
	AutoLoad.net_id = get_tree().get_network_unique_id()
	for i in AutoLoad.player_ids:
		create_player(i)
	create_player(get_tree().get_network_unique_id())


func create_player(id):
	var a = player.instance()
	a.name = str(id)
	a.position = Vector2(rand_range(-500, 500), rand_range(-300, 300))
	a.initialize(id)
	add_child(a)
