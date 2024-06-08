extends Area2D

# Constants
const MAX_HITS = 15
const NUM_FRAMES = 48
const ANGLE_PER_FRAME = 360.0 / NUM_FRAMES
const FOLLOW_RANGE = 50.0  # The range within which the enemy starts following the player

# Variables
var hits_left = MAX_HITS
var is_disappearing = false

# Nodes
@onready var sprite: Sprite2D = $Boat
@onready var player: Node2D = null  # Player reference

@export var move_speed = 30.0
@export var rotation_speed = 90.0  # Degrees per second
@export var damping_factor = 0.99
@export var acceleration_factor = 0.5

@export var area_min = Vector2(-100, -100)
@export var area_max = Vector2(100, 100)

var velocity = Vector2.ZERO
var target_angle = 0.0
var current_angle = 0.0
var rotating = false
var current_speed = 0.0
var moving_forward = true
var target_position = Vector2.ZERO

func _ready():
	if sprite:
		connect("area_entered", Callable(self, "_on_area_entered"))
		current_angle = 0.0  # Start facing east (90 degrees clockwise from north)
		update_frame()
		select_random_target()
	else:
		print("Sprite2D node not found. Please check the node name and hierarchy.")
	
	player = get_parent().get_node("Player")  # Assuming the player node is named "Player"

func _process(delta):
	if is_disappearing:
		return

	if player and (global_position.distance_to(player.global_position) <= FOLLOW_RANGE):
		follow_player(delta)
	else:
		if outside_boundary():
			select_random_target()
		else:
			move(delta)
			adjust_speed(delta)
			rotate_towards_target(delta)
	update_frame()

func select_random_target():
	moving_forward = false
	var target_x = randf_range(area_min.x, area_max.x)
	var target_y = randf_range(area_min.y, area_max.y)
	target_position = Vector2(target_x, target_y)
	rotate_to(target_position)
	moving_forward = true  # Ensure it starts moving after selecting a target

func move(delta):
	if rotating:
		return
	
	var direction = calculate_direction()
	velocity = direction * current_speed

	var new_position = global_position + velocity * delta
	if (new_position - target_position).length() < current_speed * delta:
		select_random_target()
	else:
		global_position = new_position

func rotate_to(target):
	target_angle = rad_to_deg((target - global_position).angle())
	if target_angle < 0:
		target_angle += 360
	target_angle += 90  # Adjusting for the 90 degrees clockwise offset
	if target_angle >= 360:
		target_angle -= 360

	rotating = true

func rotate_towards_target(delta):
	if not rotating:
		return

	var angle_diff = wrap_angle(target_angle - current_angle)

	if abs(angle_diff) <= rotation_speed * delta:
		current_angle = target_angle
		rotating = false  # Rotation complete
		moving_forward = true  # Start moving forward after rotation is complete
	else:
		if angle_diff > 0:
			current_angle += rotation_speed * delta
		else:
			current_angle -= rotation_speed * delta

		if current_angle < 0:
			current_angle += 360
		elif current_angle >= 360:
			current_angle -= 360

func calculate_direction():
	var angle = deg_to_rad(current_angle - 90)  # Correct for the 90 degrees clockwise offset
	return Vector2(cos(angle), sin(angle)).normalized()

func update_frame():
	var frame = int(round(current_angle / ANGLE_PER_FRAME)) % NUM_FRAMES
	if sprite:
		sprite.frame = frame

func wrap_angle(angle):
	while angle > 180:
		angle -= 360
	while angle < -180:
		angle += 360
	return angle

func adjust_speed(delta):
	if moving_forward:
		current_speed = lerp(current_speed, move_speed, acceleration_factor * delta)
	else:
		current_speed *= damping_factor

func outside_boundary():
	return global_position.x < area_min.x or global_position.x > area_max.x or global_position.y < area_min.y or global_position.y > area_max.y

func follow_player(delta):
	target_position = player.global_position
	rotate_to(target_position)
	if not rotating:
		move(delta)

func take_hit():
	if is_disappearing:
		return

	hits_left -= 1

	if hits_left <= 0:
		disappear()

func disappear():
	if sprite:
		is_disappearing = true
		sprite.visible = false
		queue_free()

func _on_area_entered(area):
	# Check if the colliding area is the player
	if area.name == "Player":
		take_hit()
