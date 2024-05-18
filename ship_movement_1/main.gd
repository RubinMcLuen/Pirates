extends Node2D

@export var rock_scene: PackedScene = preload("res://rock.tscn")
@export var number_of_rocks: int = 10
@export var spawn_area: Rect2 = Rect2(Vector2(-640, -640), Vector2(640, 640))  # Adjust the size to match your main scene's dimensions

func _ready():
	spawn_rocks()

func spawn_rocks():
	for i in range(number_of_rocks):
		var rock_instance = rock_scene.instantiate()
		rock_instance.position = get_random_position()
		add_child(rock_instance)

func get_random_position() -> Vector2:
	var x = randf() * spawn_area.size.x + spawn_area.position.x
	var y = randf() * spawn_area.size.y + spawn_area.position.y
	return Vector2(x, y)
