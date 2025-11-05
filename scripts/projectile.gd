extends Area2D

#How far away the projectile orbits
@export var orbit_radius: float = 180.0
#How fast the projectile orbits
@export var orbit_speed: float = 2.0
# How fast the projectile moves
@export var move_speed: float = 500.0
#Determines where the projectile starts orbiting. Edited in the inspector
@export var start_angle: float = 0.0
#So it won't go on forever
@export var lifetime: float = 2.0
var _life_timer: float = 0.0
var _owner: String = "enemy"

#Expects a Node2D object. To be used for its parent enemy
var _enemy: Node2D
#Angle of launch
var _angle: float
var _active: bool = false
#A 2D vector for launch direction
var _direction: Vector2 = Vector2.ZERO

# Its parent is the red enemy, and the start angle is for the position it starts rotating around the enemy. If it enters a body, calls _on_body entered
func _ready() -> void:
	_enemy = get_parent() as Node2D
	_angle = start_angle
	add_to_group("Projectile") 
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _active:
		# Move
		position += _direction * move_speed * delta
		
		# Lifetime countdown
		_life_timer -= delta
		if _life_timer <= 0.0:
			queue_free()
	else:
		# Orbit behavior
		if _enemy:
			_angle += orbit_speed * delta
			var offset = Vector2(cos(_angle), sin(_angle)) * orbit_radius
			global_position = _enemy.global_position + offset

func shoot_at(target: Node2D) -> void:
	if target:
		_direction = (target.global_position - global_position).normalized()
		_active = true
		_owner = "enemy" 
		_life_timer = lifetime   # start countdown on launch
		
func parry_from(origin: Vector2) -> void:
	print("PARRIED proj!")
	_active = true
	# send it away from the player (reverse relative to player)
	_direction = (global_position - origin).normalized()
	_owner = "player"
	_life_timer = lifetime
	

func _on_body_entered(body: Node) -> void:

	# Respect owner so parried shots don't hurt you
	if _owner == "enemy" and body.is_in_group("Player"):
		body.take_damage(1, global_position)
		queue_free()
	elif _owner == "player" and body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()
