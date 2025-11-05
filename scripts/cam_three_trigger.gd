extends Area2D
@export var target_camera: NodePath

signal raise_barrier

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		var cam := get_node_or_null(target_camera) as Camera2D
		cam.enabled = true
		cam.make_current()
		raise_barrier.emit()
