extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var time = OS.get_time()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
	

func _draws():
	var diameter: float = 0.0
	var dot_size: float = 0.0
	if get_viewport().size.x < get_viewport().size.y:
		diameter = get_viewport().size.x / 2 - 10
	else:
		diameter = get_viewport().size.y / 2 - 10
	dot_size = diameter / 100.0 * 5.0
	draw_set_transform(Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2), 0.0, Vector2(1.0, 1.0))
	draw_circle_custom(diameter, Color(1.0, 1.0, 1.0))
	draw_circle_custom(dot_size, Color(0, 0, 0))


func draw_circle_custom(radius, color, maxerror = 0.25):

	if radius <= 0.0:
		return

	var maxpoints = 1024 # I think this is renderer limit

	var numpoints = ceil(PI / acos(1.0 - maxerror / radius))
	numpoints = clamp(numpoints, 3, maxpoints)

	var points = PoolVector2Array([])

	for i in numpoints:
		var phi = i * PI * 2.0 / numpoints
		var v = Vector2(sin(phi), cos(phi))
		points.push_back(v * radius)
	draw_colored_polygon(points, color)
