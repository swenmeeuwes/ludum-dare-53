extends Node

@export var time_in_seconds_per_round: int

@export var time_left_label: Label
@export var press_to_start_label: Label
@export var ship: Ship
@export var round_timer: Timer
var draggable_spawners = []

var time_left = 0
var is_playing = false

func _ready():
	draggable_spawners = get_tree().get_nodes_in_group("draggable_spawner")
	
	_set_time_left(time_in_seconds_per_round)
	ship.move_out_of_view_instant()
	time_left_label.visible = false

func _input(event):
	if event is InputEventKey and event.pressed:
		start()

func _set_time_left(time_left_in_seconds):
	time_left = time_left_in_seconds
	
	var seconds = floor(time_left_in_seconds % 60)
	var minutes = floor((time_left_in_seconds / 60) % 60)
	time_left_label.text = "TIME LEFT: %02d:%02d" % [minutes, seconds]

func start():
	if is_playing:
		return
	
	is_playing = true
	
	ship.drag_target.clear_draggables()
	
	time_left = time_in_seconds_per_round
	_set_time_left(time_left)
	
	_hide_press_to_start_label()
	
	await ship.move_in_to_view()
	
	for draggableSpawner in draggable_spawners:
		draggableSpawner.spawn_draggable()
	
	_show_time_left_label()
	
	round_timer.start()

func end():
	round_timer.stop()
	
	for draggableSpawner in draggable_spawners:
		draggableSpawner.clear_draggable()
	
	ship.drag_target.lock_draggables()
	ship.drag_target.reparent_draggables(ship.drag_target)
	
	_hide_time_left_label()
	await ship.move_out_of_view()
	
	_show_press_to_start_label()
	
	is_playing = false

func _check_for_round_end():
	if time_left > 0:
		return
	
	end()

func _on_round_timer_timeout():
	time_left -= 1
	_set_time_left(time_left)
	
	_check_for_round_end()

func _show_time_left_label():
	time_left_label.self_modulate = Color(1, 1, 1, 0)
	time_left_label.visible = true
	
	var tween = create_tween()
	tween.tween_property(time_left_label, "self_modulate", Color(1, 1, 1, 1), .45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished

func _hide_time_left_label():
	var tween = create_tween()
	tween.tween_property(time_left_label, "self_modulate", Color(1, 1, 1, 0), .45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	time_left_label.visible = false

func _show_press_to_start_label():
	press_to_start_label.self_modulate = Color(1, 1, 1, 0)
	press_to_start_label.visible = true
	
	var tween = create_tween()
	tween.tween_property(press_to_start_label, "self_modulate", Color(1, 1, 1, 1), .45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished

func _hide_press_to_start_label():
	var tween = create_tween()
	tween.tween_property(press_to_start_label, "self_modulate", Color(1, 1, 1, 0), .45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	press_to_start_label.visible = false
