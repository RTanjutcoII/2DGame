extends Area2D
@export var target_camera: NodePath

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		var cam := get_node_or_null(target_camera) as Camera2D
		if cam:
			cam.enabled = true
			cam.make_current()
