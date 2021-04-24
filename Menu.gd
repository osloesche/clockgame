extends Node2D
var settings_file = "user://settings.save"
signal settings_loaded
var enable_music setget enable_music_set
var enable_extrainfo setget enable_extrainfo_set

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	enable_music = true
	enable_extrainfo = false
	load_settings()

func _input(event):
	if event.is_action_pressed("ui_cancel") and visible:
		fade_out()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func enable_music_set(value):
	print("Setting Music %s" % [value])
	enable_music = value
	if enable_music:
		play_anim("Unmute")
	else:
		play_anim("Mute")


func enable_extrainfo_set(value):
	print("Setting Extra Info %s" % [value])
	enable_extrainfo = value
	if enable_extrainfo:
		play_anim("ExtraInfoOn")
	else:
		play_anim("ExtraInfoOff")


func play_anim(anim):
	if $APSettings.is_playing():
		$APSettings.queue(anim)
	else:
		$APSettings.play(anim)
	

func toggle():
	if visible:
		fade_out()
	else:
		fade_in()

func fade_in():
	$AnimationPlayer.play("Load")
	
func fade_out():
	save_settings()
	$AnimationPlayer.play("Unload")

func save_settings():
	var f = File.new()
	f.open(settings_file, File.WRITE)
	f.store_var(enable_music)
	f.store_var(enable_extrainfo)
	f.close()

func load_settings():
	var f = File.new()
	if f.file_exists(settings_file):
		f.open(settings_file, File.READ)
		enable_music_set(f.get_var())
		enable_extrainfo_set(f.get_var())
		f.close()
	emit_signal("settings_loaded")
