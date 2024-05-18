extends Area2D

@export var speed = 100
@export var max_distance = 50
@export var splash_scene: PackedScene

var velocity = Vector2.ZERO
var distance_traveled = 0.0

func start(pos: Vector2, direction: Vector2):
	position = pos
	velocity = direction * speed
	distance_traveled = 0.0

func _process(delta: float):
	var movement = velocity * delta
	position += movement
	distance_traveled += movement.length()
	
	if distance_traveled > max_distance:
		create_splash_effect()
		queue_free()

func _on_area_entered(area: Area2D):
	if area.is_in_group("enemies"):
		area.call("take_hit")
		create_splash_effect()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	create_splash_effect()
	queue_free()

func create_splash_effect():
	if splash_scene:
		var splash = splash_scene.instantiate()
		splash.position = position
		get_tree().current_scene.add_child(splash)
