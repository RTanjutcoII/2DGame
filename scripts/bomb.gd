extends Area2D

@export var move_speed: float = 500.0
var _owner: String = "enemy"
@export var lifetime: float = 2.0
var _life_timer: float = 0.0
var _direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("Projectile") 
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Respect owner so parried shots don't hurt you
	if _owner == "enemy" and body.is_in_group("Player"):
		body.take_damage(2, global_position)
		queue_free()
	elif _owner == "player" and body.is_in_group("Enemy"):
		if body.has_method("take_damage_cannonball"):
			body.take_damage_cannonball(1)
			queue_free()

func _process(delta: float) -> void:
	# Move
	position += _direction * move_speed * delta
		
	# Lifetime countdown
	_life_timer -= delta
	if _life_timer <= 0.0:
		queue_free()

func shoot_at(target: Node2D) -> void:
	if target:
		_direction = (target.global_position - global_position).normalized()
		_owner = "enemy" 
		_life_timer = lifetime   # start countdown on launch

func parry_from(origin: Vector2) -> void:
	var delta := global_position - origin  # from player to bomb
	var normal: Vector2
	# choose the dominant axis as the collision normal
	if abs(delta.x) >= abs(delta.y):
		normal = Vector2(sign(delta.x), 0.0)  # left/right parry
	else:
		normal = Vector2(0.0, sign(delta.y))  # up/down parry

	_direction = _direction.bounce(normal).normalized()
	_owner = "player"
	_life_timer = lifetime
