extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(body.health, global_position)
