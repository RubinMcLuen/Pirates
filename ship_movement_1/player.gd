extends Area2D

const NUM_FRAMES = 48
const ANGLE_PER_FRAME = 360.0 / NUM_FRAMES

@export var rotation_speed = 10.0
@export var max_movement_speed = 40.0
@export var damping_factor = 0.99
@export var acceleration_factor = 0.5

var current_frame = 0
var sprite: Sprite2D = null
var velocity = Vector2.ZERO
var target_speed = 0.0
var current_speed = 0.0
var moving_forward = false

@export var cooldown = 0.2
@export var cannonball_scene : PackedScene
@export var splash_scene : PackedScene
var can_shoot = true

func _ready():
	start()
	sprite = $Boat
	if sprite:
		update_frame()
	else:
		print("Sprite2D node not found. Please check the node name and hierarchy.")

func _process(delta):
	if sprite:
		if Input.is_action_pressed("ui_right"):
			current_frame += rotation_speed * delta
			if current_frame >= NUM_FRAMES:
				current_frame -= NUM_FRAMES
			update_frame()

		if Input.is_action_pressed("ui_left"):
			current_frame -= rotation_speed * delta
			if current_frame < 0:
				current_frame += NUM_FRAMES
			update_frame()

		if Input.is_action_just_pressed("ui_select"):
			moving_forward = not moving_forward
			if moving_forward:
				target_speed = float(max_movement_speed)
			else:
				target_speed = 0.0
		
		if moving_forward:
			current_speed = lerp(current_speed, target_speed, acceleration_factor * delta)
		else:
			current_speed *= damping_factor

		var direction = calculate_direction()
		velocity = direction * current_speed
		
		position += velocity * delta
		
	if Input.is_action_pressed("shoot_left"):
		shoot_left()
	if Input.is_action_pressed("shoot_right"):
		shoot_right()

func update_frame():
	sprite.frame = int(current_frame) % NUM_FRAMES

func calculate_direction():
	var angle = (PI / 2) + (current_frame * deg_to_rad(ANGLE_PER_FRAME))
	return Vector2(-cos(angle), -sin(angle))

func start():
	$GunCooldown.wait_time = cooldown
	
func shoot_left():
	if not can_shoot:
		return
	can_shoot = false
	$GunCooldown.start()
	for i in range(5):
		var c = cannonball_scene.instantiate()
		c.splash_scene = splash_scene
		get_tree().current_scene.add_child(c)
		c.start(position + Vector2(-8, -3 + i * 3), Vector2(-1, 0))
		
func shoot_right():
	if not can_shoot:
		return
	can_shoot = false
	$GunCooldown.start()
	for i in range(5):
		var c = cannonball_scene.instantiate()
		c.splash_scene = splash_scene
		get_tree().current_scene.add_child(c)
		c.start(position + Vector2(12, -3 + i * 3), Vector2(1, 0)) 

func _on_gun_cooldown_timeout():
	can_shoot = true
