extends StaticBody2D

@onready var level = get_parent()

func _ready() -> void:
	level.lower_cannonwall.connect(_lower_cannonwall)
	
func _lower_cannonwall() -> void:
	queue_free()
