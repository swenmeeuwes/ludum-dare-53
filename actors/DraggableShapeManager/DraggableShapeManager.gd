class_name DraggableShapeManager extends Node

@export var draggable_shapes: Array[DraggableShape]

var total_random_weight: float = 0.0

func _ready():
	_initialize_probabilities()

func get_random_shape() -> DraggableShape:
	var roll = randf() * total_random_weight
	for draggable_shape in draggable_shapes:
		if draggable_shape.accumulated_random_weight > roll:
			return draggable_shape
	
	push_error("Tried getting weighted random shape, but failed.")
	return draggable_shapes[randi() % draggable_shapes.size()]

func _initialize_probabilities():
	total_random_weight = 0.0
	
	for draggable_shape in draggable_shapes:
		total_random_weight += draggable_shape.random_weight
		draggable_shape.accumulated_random_weight = total_random_weight
