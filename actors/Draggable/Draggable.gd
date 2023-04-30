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

var shape_center_0 = Vector2.ZERO
var shape_center_90 = Vector2.ZERO
var shape_center_180 = Vector2.ZERO
var shape_center_270 = Vector2.ZERO

var offset_0 = Vector2.ZERO
var offset_90 = Vector2.ZERO
var offset_180 = Vector2.ZERO
var offset_270 = Vector2.ZERO

var cell_size = 96

var held = false
var original_position: Vector2

var current_drag_target: DragTarget
var last_slotted_position = Vector2.ZERO

var can_rotate = true
var current_rotation = 0

var can_interact = true

var texture

func _ready():
	# TEST START
#	var draggable_shapes_manager = get_tree().get_first_node_in_group("DraggableShapeManager")
#	var random_shape = draggable_shapes_manager.get_random_shape()
#
#	sprite.texture = random_shape.texture
#	shape = random_shape.shape
#	shape_center = random_shape.shape_center
	# TEST END
	
	sprite.texture = texture
	update_collision_shape()
	
	original_position = global_position
	input_pickable = true # Makes _on_input_event work
	freeze = true # Disables physics by default
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC # Make it so that body enter signals are still fired
	
	recalculate_shape_center()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_interact:
			clicked.emit(self)

func _process(delta):
	if held:
		var new_pos = get_global_mouse_position()
		
		var draggable_center_offset_compensation = Vector2(shape[0].size() * .5, shape.size() * .5) * cell_size
		new_pos += draggable_center_offset_compensation
		new_pos -= Vector2.ONE * cell_size * .5 # Center on 0,0 cell
		new_pos -= shape_center * cell_size # Center on shape center
		
		
#		if (shape[0].size() - 1) * .5 != shape_center.x:
#			new_pos.x += draggable_center_offset_compensation.x * ((shape[0].size() - 1) * .5)
#
#		if (shape.size() - 1) * .5 != shape_center.y:
#			new_pos.y += draggable_center_offset_compensation.y * ((shape.size() - 1) * .5)
		
		global_position = new_pos
#		global_transform.origin = new_pos

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

func slot(drag_target: DragTarget, at):
	current_drag_target = drag_target
	
	last_slotted_position = drag_target.draggable_position_to_slot_position(self, at)
	
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "global_position", last_slotted_position, .15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func unslot():
	current_drag_target = null

func move_back_to_position():
	var target_position = original_position
	if current_drag_target != null:
		target_position = last_slotted_position
	
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "global_position", target_position, .45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func fall_off_screen_and_destroy():
	disable_interaction()
	
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "global_position", Vector2.DOWN * 1500, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).as_relative()
	
	await translate_tween.finished
	queue_free()

func disable_interaction():
	can_interact = false

func rotate_clockwise():
	if not can_rotate:
		return
	
	#print("rotate!")
	
	can_rotate = false
	
	var rotation_increment = 90
	current_rotation += rotation_increment 
	
	rotate_shape()
	
	var rotate_tween = create_tween()
	rotate_tween.tween_property(self, "rotation_degrees", rotation_increment, .15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).as_relative()
	
	await rotate_tween.finished
	
	if current_rotation >= 360:
		current_rotation = 0
		rotation_degrees = 0
	
	can_rotate = true

func rotate_shape():
	shape = rotate_array(shape)
	recalculate_shape_center()

func rotate_array(arr: Array) -> Array:
	var rotated_arr = []
	for i in range(arr[0].size()):
		var row = []
		for j in range(arr.size() - 1, -1, -1):
			row.append(arr[j][i])
		rotated_arr.append(row)
	return rotated_arr

func recalculate_shape_center():
#	print("rot", current_rotation)
	match current_rotation:
		0, 360:
			shape_center = shape_center_0
		90:
			shape_center = shape_center_90
		180:
			shape_center = shape_center_180
		270:
			shape_center = shape_center_270
	
#	print("shape_center", shape_center)
#	var center_y = max(0, ceil(shape.size() / 2) - 1)
#	var center_x = max(0, ceil(shape[0].size() / 2) - 1)
#
#	print("shape_center", shape_center)
#	shape_center = Vector2(center_x, center_y)

func update_collision_shape():
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(cell_size * shape[0].size(), cell_size * shape.size())
	
	collision_shape.shape = rect_shape

func get_slotted_offset():
	match current_rotation:
		0, 360:
			return offset_0
		90:
			return offset_90
		180:
			return offset_180
		270:
			return offset_270
