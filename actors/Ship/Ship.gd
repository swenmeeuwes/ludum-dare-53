extends Node2D

@onready var drag_target: DragTarget = $DragTarget

var initial_position

func _ready():
	initial_position = position
	drag_target.filled.connect(_on_drag_target_filled)

func _on_drag_target_filled():
	drag_target.lock_draggables()
