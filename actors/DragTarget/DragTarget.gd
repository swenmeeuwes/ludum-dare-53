class_name DragTarget extends Area2D

signal allow_draggable_to_slot(draggable, dragTarget)
signal disallow_draggable_to_slot(draggable, dragTarget)

@onready var sprite = $Sprite2D

var slotted_draggable: Draggable

func slot(draggable: Draggable):
	slotted_draggable = draggable

func unslot():
	slotted_draggable = null

func _on_body_entered(body):
	if not body.is_in_group("draggable"):
		return
	
	sprite.self_modulate = Color.GREEN
	
	var draggable = body
	allow_draggable_to_slot.emit(draggable, self)


func _on_body_exited(body):
	if not body.is_in_group("draggable"):
		return
	
	sprite.self_modulate = Color.WHITE
	
	var draggable = body
	disallow_draggable_to_slot.emit(draggable, self)
