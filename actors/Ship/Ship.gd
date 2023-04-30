class_name Ship extends Node2D

signal ship_filled(score)

@onready var drag_target: DragTarget = $DragTarget

var initial_position

func _ready():
	initial_position = position
	drag_target.filled.connect(_on_drag_target_filled)

func move_out_of_view_instant():
	position = Vector2.RIGHT * 1000

func get_score():
	return drag_target.get_score()

func _on_drag_target_filled():
	print("Ship is full!")
	
	ship_filled.emit(drag_target.get_score())
	
	drag_target.lock_draggables()
	drag_target.reparent_draggables(self)
	
	await move_out_of_view()
	drag_target.clear_draggables()
	await move_in_to_view()

func move_just_out_of_view():
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "position", Vector2.RIGHT * 1000, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	await translate_tween.finished

func move_out_of_view():
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "position", Vector2.RIGHT * 1920, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).as_relative()
	
	await translate_tween.finished

func move_in_to_view():
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "position", initial_position, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await translate_tween.finished
