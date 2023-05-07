extends Control


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")


func _on_Host_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_server(4242, 10)
	get_tree().network_peer = net


func _on_Join_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_client("127.0.0.1", 4242)
	get_tree().network_peer = net


func _player_connected(id):
	AutoLoad.player_ids.append(id)
	if AutoLoad.player_ids.size() > 0:
		get_tree().root.add_child(preload("res://scenes/Main.tscn").instance())
		queue_free()
