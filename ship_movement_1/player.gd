extends Area2D

const NUM_FRAMES = 48
const ANGLE_PER_FRAME = 360.0 / NUM_FRAMES

@export var rotation_speed = 10.0
@export var damping_factor = 0.99
@export var acceleration_factor = 0.5

var current_frame = 0
var sprite: Sprite2D = null
var velocity = Vector2.ZERO
var target_speed = 0.0
var current_speed = 0.0
var moving_forward = false

@export var cooldown = 1
@export var cannonball_scene: PackedScene
@export var splash_scene: PackedScene
@export var hit_scene: PackedScene
var can_shoot = true

@export var tilemap: TileMap

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

		adjust_speed_based_on_water()

		if moving_forward:
			current_speed = lerp(current_speed, target_speed, acceleration_factor * delta)
		else:
			current_speed *= damping_factor

		var direction = calculate_direction()
		velocity = direction * current_speed
		
		var new_position = position + velocity * delta
		var try = global_position + velocity * delta
		# Check for collision with land
		if not is_colliding_with_land(try):
			position = new_position
		else:
			print("Collision detected with land, position not updated")

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
	var ship_direction = calculate_direction()
	var left_direction = Vector2(ship_direction.y, -ship_direction.x) # Rotate 90 degrees to the left
	
	for i in range(5):
		var c = cannonball_scene.instantiate()
		c.splash_scene = splash_scene
		c.hit_scene = hit_scene
		get_tree().current_scene.add_child(c)
		# Adjust starting position based on ship direction
		var offset = ship_direction.normalized() * (i * 3 - 6) # Spread along the ship's direction
		var start_position = position + offset + left_direction * 8
		c.start(start_position, left_direction)

func shoot_right():
	if not can_shoot:
		return
	can_shoot = false
	$GunCooldown.start()
	var ship_direction = calculate_direction()
	var right_direction = Vector2(-ship_direction.y, ship_direction.x) # Rotate 90 degrees to the right
	
	for i in range(5):
		var c = cannonball_scene.instantiate()
		c.splash_scene = splash_scene
		c.hit_scene = hit_scene
		get_tree().current_scene.add_child(c)
		# Adjust starting position based on ship direction
		var offset = ship_direction.normalized() * (i * 3 - 6) # Spread along the ship's direction
		var start_position = position + offset + right_direction * 8
		c.start(start_position, right_direction)

func _on_gun_cooldown_timeout():
	can_shoot = true

func adjust_speed_based_on_water():
	if tilemap:
		var local_position = tilemap.to_local(global_position)
		var tile_position = tilemap.local_to_map(local_position)
		var tile_id = tilemap.get_cell_source_id(0, tile_position)

		match tile_id:
			0:
				target_speed = 40.0 # deep_water
			1:
				target_speed = 30.0 # normal_water
			2:
				target_speed = 20.0 # shallow_water
			_:
				target_speed = 40.0 # default speed if tile_id not recognized

func is_colliding_with_land(new_position):
	if tilemap:

		# Current position transformations
		var local_position_current = tilemap.to_local(global_position)
		var tile_position_current = tilemap.local_to_map(local_position_current)

		# New position transformations
		var local_position_new = tilemap.to_local(new_position)
		var tile_position_new = tilemap.local_to_map(local_position_new)

		var current_tile_id = tilemap.get_cell_source_id(0, tile_position_current) # Accessing layer 0 for both land and water
		var new_tile_id = tilemap.get_cell_source_id(0, tile_position_new) # Accessing layer 0 for both land and water

		if new_tile_id == 3: # Assuming 3 is the land tile ID
			print("Collision with land detected at position %s with tile ID: %s" % [new_position, new_tile_id])
			return true
	return false
