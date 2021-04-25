extends Node2D
var highscore_file = "user://highscore.save"
var highscore: Array = []


# Called when the node enters the scene tree for the first time.
func _ready():
	load_settings()
	draw_highscore()


func _input(event):
	if event.is_action_pressed("ui_cancel") and visible:
		fade_out()
	if event.is_action_pressed("ui_delete_highscore") and visible:
		delete_highscore()


func draw_highscore():
	var highscore_str = ""
	var i: int = 1
	for score in highscore:
		highscore_str += "%d. %d\n" % [i, score]
		i += 1
	$CenterContainer/clockgame_menu/label_score_list.text = highscore_str
	

func toggle():
	if visible:
		fade_out()
	else:
		fade_in()


func fade_in():
	$AnimationPlayer.play("Load")


func fade_out():
	$AnimationPlayer.play("Unload")


func submit_score(new_score: int):
	if new_score > 0 and (highscore.size() == 0 or new_score > highscore.min()):
		highscore.append(new_score)
		highscore.sort_custom(HighscoreSorter, "sort_descending")
		if highscore.size() > 9:
			highscore = highscore.slice(0, 8)
		save_settings()
		draw_highscore()


class HighscoreSorter:
	static func sort_descending(a, b):
		if a > b:
			return true
		return false


func save_settings():
	var f = File.new()
	f.open(highscore_file, File.WRITE)
	f.store_var(highscore)
	f.close()


func load_settings():
	var f = File.new()
	if f.file_exists(highscore_file):
		f.open(highscore_file, File.READ)
		highscore = f.get_var()
		f.close()


func delete_highscore():
	print("Deleting Highscore")
	highscore = []
	draw_highscore()
	var f = File.new()
	if f.file_exists(highscore_file):
		var dir = Directory.new()
		dir.remove(highscore_file)
