class_name Draggable extends RigidBody2D

signal clicked(draggable)

# 1 means that the draggable occupies this space
@export var shape = [
	[0, 1, 0],
	[0, 1, 0],
	[0, 0, 0]
]

var held = false
var original_position: Vector2

var current_drag_target: DragTarget

func _ready():
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
		global_transform.origin = get_global_mouse_position()

func drag_start():
	if held:
		return
	held = true

func drag_end():
	if held:
		held = false

func slot(drag_target: DragTarget):
	current_drag_target = drag_target
	
	var slotted_position = drag_target.draggable_position_to_slot_position(self)
	
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "position", slotted_position, .15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func unslot():
	if current_drag_target == null:
		return
	
	current_drag_target.unslot()
	current_drag_target = null

func move_back_to_original_position():
	var translate_tween = create_tween()
	translate_tween.tween_property(self, "position", original_position, .45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
