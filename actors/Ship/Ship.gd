class_name Ship extends Node2D

signal ship_filled(score)

@export var drag_target_shape_manager: DragTargetShapeManager
@export var grid_sprite: Sprite2D

@onready var drag_target: DragTarget = $DragTarget

var score_for_completing_ship
var initial_position

func _ready():
	initial_position = position
	drag_target.filled.connect(_on_drag_target_filled)
	next_shape()

func move_out_of_view_instant():
	position = Vector2.RIGHT * 1000

func get_score():
	return drag_target.get_score()

func next_shape():
	var random_target_shape = drag_target_shape_manager.get_random_shape()
	drag_target.set_shape(random_target_shape.shape.duplicate(true))
	grid_sprite.texture = random_target_shape.texture
	score_for_completing_ship = random_target_shape.score_for_completing_ship

func _on_drag_target_filled():
	print("Ship is full!")
	
	ship_filled.emit(score_for_completing_ship + drag_target.get_score())
	
	drag_target.lock_draggables()
	drag_target.reparent_draggables(self)
	
	await move_out_of_view()
	next_shape()
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
