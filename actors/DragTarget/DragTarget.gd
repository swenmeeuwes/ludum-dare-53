class_name DragTarget extends Area2D

signal allow_draggable_to_slot(draggable, dragTarget)
signal disallow_draggable_to_slot(draggable, dragTarget)
signal filled

# 1 means that there is space for a draggable there
@export var available_slots = [
	[1, 1, 1],
	[0, 1, 0],
	[1, 1, 1]
]
@export var cell_size = 96 # in pixels

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

var slotted_draggables: Array[Draggable]
var draggable_in_body: Draggable

func slot(draggable: Draggable, at):
	var relative_position = at - position
	var shape_position = _relative_position_to_shape_index_position(relative_position)
	occupy_slots(draggable, shape_position, draggable.shape_center)
	
	slotted_draggables.append(draggable)
	
	if (is_full()):
		filled.emit()

func unslot(draggable: Draggable):
	var draggable_center_offset_compensation = Vector2(draggable.shape[0].size() * .5, draggable.shape.size() * .5) * cell_size
	var relative_position = draggable.last_slotted_position - position
	
	# Remove any previously added offset
	if (draggable.shape[0].size() - 1) * .5 != draggable.shape_center.x:
		relative_position.x -= draggable_center_offset_compensation.x * ((draggable.shape[0].size() - 1) * .5)
	
	if (draggable.shape.size() - 1) * .5 != draggable.shape_center.y:
		relative_position.y -= draggable_center_offset_compensation.y * ((draggable.shape.size() - 1) * .5)
	
	var shape_position = _relative_position_to_shape_index_position(relative_position)
	print(shape_position)
	free_slots(draggable, shape_position, draggable.shape_center)
	
	print("available slots: ", available_slots)
	
	var removeIndex = slotted_draggables.find(draggable)
	slotted_draggables.remove_at(removeIndex)

func lock_draggables():
	for draggable in slotted_draggables:
		draggable.disable_interaction()

func can_slot_draggable(draggable, at):
	var relative_position = at - position
	var shape_position = _relative_position_to_shape_index_position(relative_position)
	print(relative_position, shape_position)
	
	return _shape_fits(draggable_in_body.shape, shape_position, draggable.shape_center)

func draggable_position_to_slot_position(draggable, at):
	var relative_position = at - position
	var shape_position = _relative_position_to_shape_index_position(relative_position)
	
	var draggable_center_offset_compensation = Vector2(draggable.shape[0].size() * .5, draggable.shape.size() * .5) * cell_size
	var half_size = Vector2(available_slots.size(), available_slots[0].size()) * .5 * cell_size
	var relative_position_from_top_left = relative_position - half_size
	var half_cell_size = Vector2.ONE * cell_size * .5

	var target_position = position + -half_size + shape_position * cell_size + half_cell_size
	
	# Add offset so that the visuals snap nicely
	if (draggable.shape[0].size() - 1) * .5 != draggable.shape_center.x:
		target_position.x += draggable_center_offset_compensation.x * ((draggable.shape[0].size() - 1) * .5)
	
	if (draggable.shape.size() - 1) * .5 != draggable.shape_center.y:
		target_position.y += draggable_center_offset_compensation.y * ((draggable.shape.size() - 1) * .5)
	
	return target_position

func is_full():
	for y in range(0, available_slots.size()):
		for x in range(0, available_slots[0].size()):
			if available_slots[y][x] == 1:
				return false
	
	return true

func _process(delta):
	if not draggable_in_body:
		return
	
#	var can_slot = can_slot_draggable(draggable_in_body)
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

func _shape_fits(candidate_shape, at, shape_center):
#	print(candidate_shape)
#	print("---")
#	print(at)
	for y in range(0, candidate_shape.size()):
		for x in range(0, candidate_shape[0].size()):
#			print(x, ",", y, ": ", + candidate_shape[y][x])
			var candidate_cell = candidate_shape[y][x]
			if candidate_cell == 1:
				var targetPos = Vector2(x, y) + at - shape_center
#				print(targetPos)
				if not cell_is_free(targetPos):
					return false
	
	return true

func cell_is_free(position: Vector2):
	if (position.y < 0 or position.y >= available_slots.size()):
		return false
	
	if (position.x < 0 or position.x >= available_slots[0].size()):
		return false
	
	return available_slots[position.y][position.x] == 1

func occupy_slots(draggable: Draggable, at, shape_center):
	var candidate_shape = draggable.shape
	for y in range(0, candidate_shape.size()):
		for x in range(0, candidate_shape[0].size()):
			var candidate_cell = candidate_shape[y][x]
			if candidate_cell == 1:
				var targetPos = Vector2(x, y) + at - shape_center
				if cell_is_free(targetPos):
					print(targetPos, "no longer available")
					available_slots[targetPos.y][targetPos.x] = 0
				else:
					push_warning("[DragManager] Tried to occupy already occupied slot.")

func free_slots(draggable: Draggable, at, shape_center):
	var candidate_shape = draggable.shape
	for y in range(0, candidate_shape.size()):
		for x in range(0, candidate_shape[0].size()):
			var candidate_cell = candidate_shape[y][x]
			if candidate_cell == 1:
				var targetPos = Vector2(x, y) + at - shape_center
				if cell_is_free(targetPos):
					push_warning("[DragManager] Tried to free already freed slot.")
				else:
					print(targetPos, "freed")
					available_slots[targetPos.y][targetPos.x] = 1

# outputs indexes of available_slot array of arrays
func _relative_position_to_shape_index_position(relative_position: Vector2):
	var pos = relative_position + Vector2(available_slots.size() * .5, available_slots[0].size() *.5) * cell_size
	return floor(pos / cell_size)
