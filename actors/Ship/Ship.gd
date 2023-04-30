extends Node2D

@onready var drag_target: DragTarget = $DragTarget

var initial_position

func _ready():
	initial_position = position
	drag_target.filled.connect(_on_drag_target_filled)

func _on_drag_target_filled():
	drag_target.lock_draggables()
	drag_target.reparent_draggables(self)
	
	_move_out_of_view()
	print("Ship is full!")

func _move_out_of_view():
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "position", Vector2.RIGHT * 1920, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).as_relative()
	
	await translate_tween.finished
	
