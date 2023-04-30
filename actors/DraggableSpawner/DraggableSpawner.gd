extends Node2D

var draggable_scene = preload("res://actors/Draggable/Draggable.tscn")

@onready var spawn_timer: Timer = $SpawnTimer
@export var drag_manager: DragManager
var draggable_shapes_manager: DraggableShapeManager

var current_draggable

func _ready():
	draggable_shapes_manager = get_tree().get_first_node_in_group("DraggableShapeManager")
	_spawn_draggable()

func _spawn_draggable():
	var draggable = draggable_scene.instantiate()
	get_parent().add_child.call_deferred(draggable)
	draggable.global_position = global_position
	
	var random_shape = draggable_shapes_manager.get_random_shape()

	draggable.texture = random_shape.texture
	draggable.shape = random_shape.shape
	draggable.shape_center = random_shape.shape_center
	
	current_draggable = draggable
	current_draggable.clicked.connect(_on_draggable_clicked)
	
	drag_manager.register_draggable(draggable)

func _on_draggable_clicked(draggable: Draggable):
	draggable.clicked.disconnect(_on_draggable_clicked)
	spawn_timer.start()

func _on_timer_timeout():
	_spawn_draggable()
