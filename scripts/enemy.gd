extends CharacterBody2D
signal defeated

@export var bob_height: float = 5.0
@export var bob_speed: float = 2.0
@export var player: NodePath
@export var delay_between_shots: float = 3.0
@export var health: int = 3
@export var projectile_scene: PackedScene

var _time: float = 0.0
var _projectiles: Array = []
var _launching: bool = false
var _player_in_range: bool = false

func _ready() -> void:
	# Track existing projectiles in editor (optional case)
	for child in get_children():
		if child.has_method("shoot_at"):
			_projectiles.append(child)
			child.tree_exited.connect(func(): _on_projectile_tree_exited(child))

	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)
	$DetectionArea.body_entered.connect(_on_body_entered)
	$DetectionArea.body_exited.connect(_on_body_exited)
	$AnimatedSprite2D.play("default")

	# If none placed, spawn 3 to start
	if _projectiles.is_empty():
		_spawn_projectiles(3)

func _process(delta: float) -> void:
	_time += delta * bob_speed
	position.y += sin(_time) * (bob_height * delta)

	if _player_in_range and not _launching and $AnimatedSprite2D.animation == "default":
		attack()

func attack() -> void:
	$AnimatedSprite2D.play("attack")

func _on_frame_changed() -> void:
	if $AnimatedSprite2D.animation == "attack" and $AnimatedSprite2D.frame == 2:
		if not _launching:
			_launching = true
			_launch_projectiles()

func _launch_projectiles() -> void:
	var player_node := get_node_or_null(player)
	if player_node == null:
		_launching = false
		$AnimatedSprite2D.play("default")
		return

	for p in _projectiles.duplicate():
		if p and is_instance_valid(p):
			p.shoot_at(player_node)
			$AnimatedSprite2D.play("default")
			await get_tree().create_timer(delay_between_shots).timeout
			if _player_in_range:
				$AnimatedSprite2D.play("attack")

	_clean_projectile_list()

	# If every projectile has been fired & destroyed, spawn new set
	if _projectiles.is_empty():
		_spawn_projectiles(3)

	_launching = false
	$AnimatedSprite2D.play("default")

func _spawn_projectiles(count: int) -> void:
	if projectile_scene == null:
		push_warning("No projectile_scene set in Inspector.")
		return

	for i in range(count):
		var p = projectile_scene.instantiate()
		add_child(p)

		# Position in a circle around enemy
		var angle := (TAU / float(count)) * i
		p.set("start_angle", angle)

		_projectiles.append(p)
		p.tree_exited.connect(func(): _on_projectile_tree_exited(p))

func _on_projectile_tree_exited(node: Node) -> void:
	_projectiles.erase(node)

	# Only respawn a FULL SET when empty
	if _projectiles.is_empty() and not _launching:
		_spawn_projectiles(3)

func _clean_projectile_list() -> void:
	_projectiles = _projectiles.filter(func(n): return n != null and is_instance_valid(n))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		_player_in_range = true
		$AnimatedSprite2D.play("attack")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		_player_in_range = false
		$AnimatedSprite2D.play("default")

func take_damage(amount: int) -> void:
	health -= amount
	$AnimationPlayer.play("hit_flash")
	$AnimationPlayer.queue("RESET")
	if health <= 0:
		die()

func die() -> void:
	defeated.emit()
	queue_free()

func attack_cooldown() -> void:
	$AnimatedSprite2D.play("default")
