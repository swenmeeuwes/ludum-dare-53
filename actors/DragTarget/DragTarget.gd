class_name DragTarget extends Area2D

signal allow_draggable_to_slot(draggable, dragTarget)
signal disallow_draggable_to_slot(draggable, dragTarget)

# 1 means that there is space for a draggable there
@export var available_slots = [
	[1, 1, 1],
	[0, 1, 0],
	[1, 1, 1]
]
@export var cell_size = 32 # in pixels

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

var slotted_draggable: Draggable
var draggable_in_body: Draggable

func slot(draggable: Draggable):
	slotted_draggable = draggable

func can_slot_draggable(draggable):
	var relative_position = draggable_in_body.position - position
	var shape_position = _world_position_to_shape_position(relative_position)
	
	return _shape_fits(draggable_in_body.shape, shape_position)

func draggable_position_to_slot_position(draggable):
	var relative_position = draggable_in_body.position - position
	var shape_position = _world_position_to_shape_position(relative_position)
	
	return position + shape_position * cell_size

func unslot():
	slotted_draggable = null

func _process(delta):
	if not draggable_in_body:
		return
	
	var can_slot = can_slot_draggable(draggable_in_body)
#	print(fits)

func _on_body_entered(body):
	if not body.is_in_group("draggable"):
		return
	
	var draggable = body
	allow_draggable_to_slot.emit(draggable, self)
	
	draggable_in_body = draggable;


func _on_body_exited(body):
	if not body.is_in_group("draggable"):
		return
	
	var draggable = body
	disallow_draggable_to_slot.emit(draggable, self)
	
	draggable_in_body = null

func _shape_fits(candidate_shape, at):
	#print(candidate_shape)
	for y in range(0, candidate_shape.size()):
		for x in range(0, candidate_shape[0].size()):
			# print(x, ",", y, ": ", + shape[y][x])
			var candidate_cell = candidate_shape[y][x]
			if candidate_cell == 1:
				var targetPos = Vector2(x, y) + at
				if not cell_is_free(targetPos):
					return false
	
	return true

func cell_is_free(position: Vector2):
	if (position.y < 0 or position.y >= available_slots.size()):
		return false
	
	if (position.x < 0 or position.x >= available_slots[0].size()):
		return false
	
	return available_slots[position.y][position.x] == 1

func _world_position_to_shape_position(world_position: Vector2):
	return round(world_position / cell_size)
