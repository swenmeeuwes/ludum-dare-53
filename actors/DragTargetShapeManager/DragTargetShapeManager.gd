class_name DragTargetShapeManager extends Node

@export var drag_target_shapes: Array[DragTargetShape]

func get_random_shape() -> DragTargetShape:
	return drag_target_shapes[randi() % drag_target_shapes.size()]
