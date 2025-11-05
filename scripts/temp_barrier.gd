extends StaticBody2D

@onready var level = get_parent()

func _ready() -> void:
	level.lower_barrier.connect(_lower_barrier)
	
func _lower_barrier() -> void:
	queue_free()
