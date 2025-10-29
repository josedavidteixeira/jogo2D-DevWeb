extends Camera2D

var target: Node2D

func _ready() -> void:
	get_target()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = target.position

func get_target():
	var nodes = get_tree().get_nodes_in_group("player")
	if nodes.size() == 0:
		push_error("player not found")
		return
	target = nodes[0]
