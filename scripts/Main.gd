extends Node

@export var time_in_seconds_per_round: int

@export var time_left_label: Label
@export var press_to_start_label: Label
@export var score_label: Label
@export var final_score_label: Label
@export var made_by_label: Label
@export var game_name_label: Label
@export var ship: Ship
@export var round_timer: Timer
@export var play_mode_audio: AudioStreamPlayer2D
@export var idle_mode_audio: AudioStreamPlayer2D
@export var start_audio: AudioStreamPlayer2D
var draggable_spawners = []

var time_left = 0
var score = 0
var is_playing = false
var ended = false

func _ready():
	draggable_spawners = get_tree().get_nodes_in_group("draggable_spawner")
	
	_set_time_left(time_in_seconds_per_round)
	ship.move_out_of_view_instant()
	time_left_label.visible = false
	score_label.visible = false
	final_score_label.visible = false
	
	ship.ship_filled.connect(_on_ship_filled)
	
	idle_mode_audio.play()

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton and event.pressed:
		start()

func _set_time_left(time_left_in_seconds):
	time_left = time_left_in_seconds
	
	var seconds = floor(time_left_in_seconds % 60)
	var minutes = floor((time_left_in_seconds / 60) % 60)
	time_left_label.text = "TIME LEFT: %02d:%02d" % [minutes, seconds]

func _add_score(add_score):
	_set_score(score + add_score)

func _set_score(new_score):
	score = new_score
	
	score_label.text = "SCORE: %05d" % [score]

func start():
	if is_playing:
		return
	
	start_audio.play()
	
	if ended:
		get_tree().reload_current_scene()
		return
	
	is_playing = true
	
	ship.drag_target.clear_draggables()
	
	time_left = time_in_seconds_per_round
	_set_time_left(time_left)
	
	score = 0
	_set_score(score)
	
	_hide_label(press_to_start_label)
	_hide_label(final_score_label)
	_hide_label(made_by_label)
	_hide_label(game_name_label)
	
	var idle_mode_audio_tween = create_tween()
	idle_mode_audio_tween.tween_property(idle_mode_audio, "volume_db", -80, 2)
	await ship.move_in_to_view()
	
	await _show_label(time_left_label)
	await _show_label(score_label)
	
	for draggableSpawner in draggable_spawners:
		draggableSpawner.spawn_draggable()
	

#	play_mode_audio.volume_db = -80
#	play_mode_audio.play()
	
#	var play_mode_audio_tween = create_tween()
#	play_mode_audio_tween.tween_property(play_mode_audio, "volume_db", 0, .65)
#	await play_mode_audio_tween.finished
	
	idle_mode_audio.stop()
	play_mode_audio.play()
	
	round_timer.start()

func end():
	round_timer.stop()
	play_mode_audio.stop()
	
	idle_mode_audio.play()
	
#	_add_score(ship.get_score())
	
	final_score_label.text = "FINAL SCORE: %05d" % score
	press_to_start_label.text = "- Press any key to reset -"
	
	for draggableSpawner in draggable_spawners:
		draggableSpawner.clear_draggable()
	
	ship.drag_target.lock_draggables()
	ship.drag_target.reparent_draggables(ship.drag_target)
	
	_hide_label(time_left_label)
	_hide_label(score_label)
	
	await ship.move_out_of_view()
	ship.move_just_out_of_view()
	
	await _show_label(final_score_label)
	await _show_label(press_to_start_label)
	await _show_label(made_by_label)
	
	is_playing = false
	ended = true

func _check_for_round_end():
	if time_left > 0:
		return
	
	end()

func _on_round_timer_timeout():
	time_left -= 1
	_set_time_left(time_left)
	
	_check_for_round_end()

func _on_ship_filled(score):
	_add_score(score)

# Label show/ hide functions
func _show_label(label):
	label.self_modulate = Color(label.self_modulate.r, label.self_modulate.g, label.self_modulate.b, 0)
	label.visible = true
	
	var tween = create_tween()
	tween.tween_property(label, "self_modulate", Color(label.self_modulate.r, label.self_modulate.g, label.self_modulate.b, 1), .45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished

func _hide_label(label):
	var tween = create_tween()
	tween.tween_property(label, "self_modulate", Color(label.self_modulate.r, label.self_modulate.g, label.self_modulate.b, 0), .45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	label.visible = false
