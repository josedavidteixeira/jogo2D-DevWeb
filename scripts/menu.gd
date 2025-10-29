extends Control



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("C:/Users/Compucenter/Documents/jogo-2d-dev-web/scene/forest.tscn")


func _on_exit_pressed() -> void:
	get_tree().guit()
