class_name DraggableSpawner extends Node2D

var draggable_scene = preload("res://actors/Draggable/Draggable.tscn")

@onready var spawn_timer: Timer = $SpawnTimer
@export var drag_manager: DragManager
var draggable_shapes_manager: DraggableShapeManager

var current_draggable

func _ready():
	draggable_shapes_manager = get_tree().get_first_node_in_group("DraggableShapeManager")

func spawn_draggable():
	var draggable = draggable_scene.instantiate()
	get_parent().add_child.call_deferred(draggable)
	draggable.global_position = global_position
	
	var random_shape = draggable_shapes_manager.get_random_shape()

	draggable.texture = random_shape.texture
	draggable.shape = random_shape.shape
	draggable.shape_center_0 = random_shape.shape_center_0
	draggable.shape_center_90 = random_shape.shape_center_90
	draggable.shape_center_180 = random_shape.shape_center_180
	draggable.shape_center_270 = random_shape.shape_center_270
	
	draggable.offset_0 = random_shape.offset_0
	draggable.offset_90 = random_shape.offset_90
	draggable.offset_180 = random_shape.offset_180
	draggable.offset_270 = random_shape.offset_270
	
	draggable.score = random_shape.score
	
	current_draggable = draggable
	current_draggable.clicked.connect(_on_draggable_clicked)
	
	drag_manager.register_draggable(draggable)

func clear_draggable():
	if not current_draggable:
		return
	
#	current_draggable.clicked.disconnect(_on_draggable_clicked)
	current_draggable.queue_free()
	current_draggable = null
	
	spawn_timer.stop()

func _on_draggable_clicked(draggable: Draggable):
	draggable.clicked.disconnect(_on_draggable_clicked)
	spawn_timer.start()

func _on_timer_timeout():
	spawn_draggable()
