extends Node2D


var held_draggable: Draggable
var entered_drag_target: DragTarget

func _ready():
	_initialize_dragging()

func _initialize_dragging():
	for draggable in get_tree().get_nodes_in_group("draggable"):
		draggable.clicked.connect(_on_draggable_clicked)
	
	for drag_target in get_tree().get_nodes_in_group("drag_target"):
		drag_target.allow_draggable_to_slot.connect(_on_allow_draggable_to_slot)
		drag_target.disallow_draggable_to_slot.connect(_on_disallow_draggable_to_slot)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_draggable and !event.pressed:
			held_draggable.drag_end()
			if entered_drag_target == null:
				held_draggable.unslot()
				held_draggable.move_back_to_original_position()
			else:
				held_draggable.slot(entered_drag_target)
			held_draggable = null

func _on_draggable_clicked(draggable: Draggable):
	if !held_draggable:
		held_draggable = draggable
		draggable.drag_start()

func _on_allow_draggable_to_slot(draggable: Draggable, dragTarget: DragTarget):
	entered_drag_target = dragTarget

func _on_disallow_draggable_to_slot(draggable: Draggable, dragTarget: DragTarget):
	entered_drag_target = null
