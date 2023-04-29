class_name Draggable extends RigidBody2D

signal clicked(draggable)

# 1 means that the draggable occupies this space
@export var shape = [
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
		var new_pos = get_global_mouse_position()# + Vector2((shape_center.x * .5), (shape_center.y * .5)) * cell_size
		global_transform.origin = new_pos

func drag_start():
	if held:
		return
	held = true

func drag_end():
	if held:
		held = false

func slot(drag_target: DragTarget):
	current_drag_target = drag_target
	
	last_slotted_position = drag_target.draggable_position_to_slot_position(self)
	
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "position", last_slotted_position, .15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func unslot():
	current_drag_target = null

func move_back_to_original_position():
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "position", original_position, .45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
