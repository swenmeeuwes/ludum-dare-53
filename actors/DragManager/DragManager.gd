class_name DragManager extends Node2D


var held_draggable: Draggable
var entered_drag_target: DragTarget

var right_mouse_button_was_pressed = false

func _ready():
	_initialize_dragging()

func register_draggable(draggable: Draggable):
	draggable.clicked.connect(_on_draggable_clicked)

func register_drag_target(drag_target: DragTarget):
	drag_target.allow_draggable_to_slot.connect(_on_allow_draggable_to_slot)
	drag_target.disallow_draggable_to_slot.connect(_on_disallow_draggable_to_slot)

func _initialize_dragging():
	for draggable in get_tree().get_nodes_in_group("draggable"):
		draggable.clicked.connect(_on_draggable_clicked)
	
	for drag_target in get_tree().get_nodes_in_group("drag_target"):
		drag_target.allow_draggable_to_slot.connect(_on_allow_draggable_to_slot)
		drag_target.disallow_draggable_to_slot.connect(_on_disallow_draggable_to_slot)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if is_instance_valid(held_draggable) and held_draggable and !event.pressed:
			held_draggable.drag_end()
			if entered_drag_target == null:
#				print("entered_drag_target == null")
				if held_draggable.current_drag_target != null:
					held_draggable.current_drag_target.unslot(held_draggable)
				held_draggable.unslot()
				held_draggable.fall_off_screen_and_destroy()
			else:
				var canSlot = entered_drag_target.can_slot_draggable(held_draggable, event.position)
				if canSlot:
					held_draggable.slot(entered_drag_target, event.position)
					entered_drag_target.slot(held_draggable, event.position)
				else:
					held_draggable.fall_off_screen_and_destroy()
			held_draggable = null
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if is_instance_valid(held_draggable) and held_draggable and event.pressed and not right_mouse_button_was_pressed:
			held_draggable.rotate_clockwise();
			right_mouse_button_was_pressed = true
		
		if not event.pressed:
			right_mouse_button_was_pressed = false


func _on_draggable_clicked(draggable: Draggable):
	if held_draggable:
		return
	
	if draggable.current_drag_target:
		if draggable.current_drag_target != null:
					draggable.current_drag_target.unslot(draggable)
		draggable.unslot()
		draggable.fall_off_screen_and_destroy()
		return
	
	held_draggable = draggable
	draggable.drag_start()

func _on_allow_draggable_to_slot(draggable: Draggable, dragTarget: DragTarget):
	if held_draggable == draggable:
		entered_drag_target = dragTarget

func _on_disallow_draggable_to_slot(draggable: Draggable, dragTarget: DragTarget):
	if held_draggable == draggable:
		entered_drag_target = null
