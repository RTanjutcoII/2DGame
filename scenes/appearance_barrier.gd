extends StaticBody2D

@onready var raise_trigger = $"../CamThreeTrigger"
@onready var lower_trigger = $"../CamTwoTrigger"

func _ready() -> void:
	$CollisionShape2D.disabled = true
	raise_trigger.raise_barrier.connect(_raise_barrier)
	lower_trigger.lower_barrier.connect(_lower_barrier)

func _raise_barrier() -> void:
	$CollisionShape2D.set_deferred("disabled", false)
	
func _lower_barrier() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
