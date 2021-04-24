extends Node2D
onready var time = OS.get_time()
onready var time_est = "00:00"
onready var game_running: bool = false
onready var rng = RandomNumberGenerator.new()
onready var hour_fraction: float = 0.0
onready var minute_fraction: float = 0.0
onready var degrees_hour: float = 0.0
onready var degrees_minute: float = 0.0
onready var is_am: bool = true

func _ready():
	$AnimationPlayer.get_animation("Clock").loop = true
	$AnimationPlayer.play("Clock")
	$APBG_rocks_1.play("Parallax")
	$APBG_rocks_2.play("Parallax")
	$APBG_clouds_1.play("Parallax")
	$APBG_clouds_2.play("Parallax")
	rng.randomize()
	set_ampm()

func _input(event):
	if event.is_action_pressed("ui_hint"):
		hint()
	if event.is_action_pressed("ui_set"):
		$Settings.toggle()
	if event.is_action_pressed("ui_quit"):
		get_tree().quit()
	if event.is_action_pressed("ui_mute"):
		$AudioStreamPlayerBG.playing = !$AudioStreamPlayerBG.playing
		$Settings.enable_music = $AudioStreamPlayerBG.playing
		$Settings.save_settings()
	if event.is_action_pressed("ui_extrainfo"):
		$Settings.enable_extrainfo = !$Settings.enable_extrainfo
		$Settings.save_settings()
		check_extrainfo()
	if event.is_action_pressed("ui_settime"):
		new_time($HourSlider.value, $MinuteSlider.value)

func calc_degrees():
	hour_fraction = float(time.hour) + map(float(time.minute), 0.0, 60.0, 0.0, 1.0)
	minute_fraction = float(time.minute) + map(float(time.second), 0.0, 60.0, 0.0, 1.0)
	degrees_hour = map(hour_fraction, 0.0, 24.0, 0.0, 720.0)
	degrees_minute = map(minute_fraction, 0.0, 60.0, 0.0, 360.0)

func _physics_process(_delta):
	if !game_running:
		time = OS.get_time()
	calc_degrees()
	time_est = "%02d:%02d" % [$HourSlider.value, $MinuteSlider.value]
	$CenterContainer/TimeEst.text = time_est

func _process(_delta):
	if $APClock.is_playing():
		return
	$"clock frame/little hand".rotation_degrees = degrees_hour
	$"clock frame/big hand".rotation_degrees = degrees_minute

func map(x, in_min, in_max, out_min, out_max):
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;

func _on_AnimationPlayer_animation_finished(anim_name):
	$AnimationPlayer.play(anim_name)

func _on_HourSlider_value_changed(_value):
	pass # Replace with function body.

func _on_MinuteSlider_value_changed(_value):
	pass # Replace with function body.

func _on_Submit_pressed():
	if $APSubmit.is_playing() or $APClock.is_playing():
		return
	var min_valid_minute = time.minute - 1
	var max_valid_minute = time.minute + 1
	print("Current time: %d:%d  Guess was: %d:%d  Degrees: %f, %f" % [time.hour, time.minute, $HourSlider.value, $MinuteSlider.value, degrees_hour, degrees_minute])

	if $HourSlider.value == time.hour and $MinuteSlider.value >= min_valid_minute and $MinuteSlider.value <= max_valid_minute:
		$Fireworks.emitting = true
		$APSubmit.play("Correct")
		$AudioStreamPlayerCorrect.play()
		new_time()
	else:
		$APSubmit.play("Wrong")
		$AudioStreamPlayerWrong.play()

func new_time(hour: int = -1, minute: int = -1):
	game_running = true
	var old_degrees_hour = degrees_hour
	var old_degrees_minute = degrees_minute
	if hour >= 0:
		time.hour = hour
	else:
		time.hour = rng.randi_range(0, 23)
	if minute >= 0:
		time.minute = minute
	else:
		time.minute = rng.randi_range(0, 59)
	time.second = 0
	calc_degrees()
	var anim = Animation.new()
	$APClock.add_animation("next_round", anim)
	anim.add_track(0)
	anim.add_track(0)
	anim.length = 1
	anim.track_set_path(0, "clock frame/little hand:rotation_degrees")
	anim.track_set_path(1, "clock frame/big hand:rotation_degrees")
	anim.track_insert_key(0, 0.0, old_degrees_hour)
	anim.track_insert_key(0, 1.0, degrees_hour)
	anim.track_insert_key(1, 0.0, old_degrees_minute)
	anim.track_insert_key(1, 1.0, degrees_minute)
	$APClock.play("next_round")
	set_ampm()

func _on_APClock_animation_finished(anim_name):
	if anim_name == "next_round":
		$APClock.remove_animation(anim_name)

func set_ampm():
	if time.hour >= 6 and time.hour < 18:
		if !is_am:
			$APBG.play("Day")
			is_am = true
	else:
		if is_am:
			$APBG.play("Night")
			is_am = false


func _on_Settings_settings_loaded():
	$AudioStreamPlayerBG.playing = $Settings.enable_music
	check_extrainfo()

func check_extrainfo():
	if $Settings.enable_extrainfo:
		$inner_rune.visible = false
		$inner_seconds.visible = true
	else:
		$inner_rune.visible = true
		$inner_seconds.visible = false

func hint():
	if $APSubmit.is_playing() or $APClock.is_playing():
		return
	var anim = Animation.new()
	$APClock.add_animation("Hint", anim)
	anim.add_track(0)
	anim.add_track(0)
	anim.length = 0.2
	anim.track_set_path(0, "HourSlider:value")
	anim.track_set_path(1, "MinuteSlider:value")
	anim.track_insert_key(0, 0.0, $HourSlider.value)
	anim.track_insert_key(0, 0.2, time.hour)
	anim.track_insert_key(1, 0.0, $MinuteSlider.value)
	anim.track_insert_key(1, 0.2, time.minute)
	$APClock.play("Hint")


func _on_APHint_animation_finished(anim_name):
	$APHint.remove_animation(anim_name)
