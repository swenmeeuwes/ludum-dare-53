class_name GridHelper

const grid_size = 32

static func snap_position_to_grid(position):
	var x_off = int(position.x) % grid_size
	var y_off = int(position.y) % grid_size
	
	return Vector2(position.x - x_off, position.y - y_off)

static func get_center_position_of_cell_offset(cell_position):
	pass
