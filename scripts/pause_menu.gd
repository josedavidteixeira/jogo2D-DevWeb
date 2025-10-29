extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false 
@onready var resume_btn: Button = $menu_holder/resume_btn


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = true
		get_tree().paused = true
		resume_btn.grab_focus()

func _on_resume_btn_pressed() -> void:
	get_tree().paused = false
	visible = false



func _on_quit_btn_pressed() -> void:
	get_tree().guit()
