extends Area2D
@export var target_camera: NodePath
@export var checkpoint_spawn: NodePath 

signal raise_barrier

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		var cam := get_node_or_null(target_camera) as Camera2D
		if cam:
			cam.enabled = true
			cam.make_current()
		raise_barrier.emit()
		var spawn := get_node_or_null(checkpoint_spawn) as Node2D
		if body.has_method("set_checkpoint"):
			if spawn:
				body.set_checkpoint(spawn.global_position)
			else:
				# Fallback: use this trigger's position
				body.set_checkpoint(global_position)
