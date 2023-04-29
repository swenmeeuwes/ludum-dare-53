class_name Draggable extends RigidBody2D

signal clicked(draggable)

# 1 means that the draggable occupies this space
@export var shape: Array = [
	[0, 0, 0],
	[0, 0, 0],
	[0, 0, 0]
]

@onready var sprite = $Sprite
@onready var collision_shape = $CollisionShape2D
var shape_center = Vector2.ZERO

var cell_size = 32

var held = false
var original_position: Vector2

var current_drag_target: DragTarget
var last_slotted_position = Vector2.ZERO

var can_rotate = true
var current_rotation = 0

func _ready():
	# TEST START
	var draggable_shapes_manager = get_tree().get_first_node_in_group("DraggableShapeManager")
	var random_shape = draggable_shapes_manager.get_random_shape()

	sprite.texture = random_shape.texture
	shape = random_shape.shape
	shape_center = random_shape.shape_center

	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(cell_size * shape[0].size(), cell_size * shape.size())
	collision_shape.shape = rect_shape
	# TEST END
	
	original_position = position
	input_pickable = true # Makes _on_input_event work
	freeze = true # Disables physics by default
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC # Make it so that body enter signals are still fired

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)

func _process(delta):
	if held:
		var new_pos = get_global_mouse_position()
		
		var draggable_center_offset_compensation = Vector2(shape[0].size() * .5, shape.size() * .5) * cell_size
		if (shape[0].size() - 1) * .5 != shape_center.x:
			new_pos.x += draggable_center_offset_compensation.x * ((shape[0].size() - 1) * .5)
		
		if (shape.size() - 1) * .5 != shape_center.y:
			new_pos.y += draggable_center_offset_compensation.y * ((shape.size() - 1) * .5)
		
		global_transform.origin = new_pos

func drag_start():
	if held:
		return
	
	_move_to_front()
	held = true

func drag_end():
	if held:
		held = false

func _move_to_front():
	get_parent().move_child(self, get_parent().get_child_count())

func slot(drag_target: DragTarget):
	current_drag_target = drag_target
	
	last_slotted_position = drag_target.draggable_position_to_slot_position(self)
	
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "position", last_slotted_position, .15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func unslot():
	current_drag_target = null

func move_back_to_position():
	var target_position = original_position
	if current_drag_target != null:
		target_position = last_slotted_position
	
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "position", target_position, .45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func rotate_clockwise():
	if not can_rotate:
		return
	
	#print("rotate!")
	
	can_rotate = false
	
	var rotation_increment = 90
	current_rotation += rotation_increment 
	
	rotate_shape()
	
	var rotate_tween = create_tween()
	await rotate_tween.tween_property(self, "rotation_degrees", rotation_increment, .15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).as_relative()
	
	can_rotate = true

func rotate_shape():
	shape = rotate_array(shape)
	
func rotate_array(arr: Array) -> Array:
	var rotated_arr = []
	for i in range(arr[0].size()):
		var row = []
		for j in range(arr.size() - 1, -1, -1):
			row.append(arr[j][i])
		rotated_arr.append(row)
	return rotated_arr
