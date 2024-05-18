extends Area2D

# Constants
const MAX_HITS = 15
const HITS_PER_FRAME = 5

# Variables
var hits_left = MAX_HITS
var is_exploding = false

# Nodes
@onready var rock_sprite = $Sprite2D
@onready var explosion_sprite = $AnimatedSprite2D

func _ready():
	# Set the initial frame
	rock_sprite.frame = 0
	explosion_sprite.visible = false
	explosion_sprite.connect("animation_finished", Callable(self, "_on_explosion_finished"))

func take_hit():
	if is_exploding:
		return
	
	hits_left -= 1
	update_sprite_frame()

	if hits_left <= 0:
		explode()

func update_sprite_frame():
	if hits_left > 0:
		var current_frame = (MAX_HITS - hits_left) / HITS_PER_FRAME
		rock_sprite.frame = current_frame

func explode():
	is_exploding = true
	rock_sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("explosion")  # Ensure the explosion animation is named "explosion"

func _on_explosion_finished():
	queue_free()
