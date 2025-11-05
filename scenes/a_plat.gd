extends StaticBody2D

@export var enemy_a : NodePath
@export var enemy_b : NodePath

signal spawned

var dead_count := 0

func _ready() -> void:
	# Start disabled
	$CollisionShape2D.disabled = true
	$MeshInstance2D.visible = false
	
	print (enemy_a, enemy_b)

	# Connect to both enemies
	var e1 = get_node(enemy_a)
	var e2 = get_node(enemy_b)

	if e1.has_signal("defeated"):
		e1.connect("defeated", _on_enemy_defeated)

	if e2.has_signal("defeated"):
		e2.connect("defeated", _on_enemy_defeated)


func _on_enemy_defeated() -> void:
	dead_count += 1
	if dead_count >= 2:
		$CollisionShape2D.set_deferred("disabled", false)
		$MeshInstance2D.set_deferred("visible", true)
		spawned.emit()
