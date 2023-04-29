class_name DraggableShapeManager extends Node

@export var draggable_shapes: Array[DraggableShape]

func get_random_shape() -> DraggableShape:
	return draggable_shapes[randi() % draggable_shapes.size()]
