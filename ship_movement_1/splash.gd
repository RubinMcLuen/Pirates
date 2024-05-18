extends AnimatedSprite2D

func _ready():
	play()
	connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_animation_finished():
	queue_free()
