extends CharacterBody2D

signal health_changed(current: int, max: int)
signal dead

@export var initial_checkpoint: NodePath 
var _checkpoint: Vector2
@export var max_health: int = 5
var health: int = max_health
@export var speed: float = 500
@export var gravity: float = 2000
@export var jump_force: float = 800
@export var knockback_force: float = 600.0    # horizontal push
@export var knockup_force: float = 200.0      # small upward bump
@export var hurt_stun: float = 0.18           # time you can't move
@export var attack_cooldown: float = 0.35
var facing_right: bool = true
var cd: float = 0.0

var alive = true;
var can_control = true

var jumps_available: int = 2
var MAX_JUMPS: int = 2

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	
	var cp := get_node_or_null(initial_checkpoint) as Node2D
	if cp:
		_checkpoint = cp.global_position
	else:
		_checkpoint = global_position  # fallback
	
	emit_signal("health_changed", health, max_health)

func _physics_process(delta):
	
	if not alive:
		if !is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if cd > 0.0:
		cd = max(cd - delta, 0.0)
	# If in the air, fall down (with maximum fall velocity)
	if !is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 1200:
			velocity.y = 1200
	
	# Jump
	if Input.is_action_just_pressed("ui_up") && jumps_available > 1 && alive && can_control:
		velocity.y = -jump_force
		jumps_available -= 1
	
	# Resets double jump count
	if is_on_floor():
		jumps_available = MAX_JUMPS
	
	# Moves left and right using move_and_slide()
	var xdirect = Input.get_axis("ui_left", "ui_right")

	if alive and can_control:
		velocity.x = speed * xdirect

		# Only update facing when there is movement input
		if xdirect != 0:
			facing_right = xdirect > 0

		# Apply facing
		$AnimatedSprite2D.flip_h = not facing_right

		# Flip swing hitbox
		if facing_right:
			$SwingRange.scale.x = abs($SwingRange.scale.x)
		else:
			$SwingRange.scale.x = -abs($SwingRange.scale.x)
		
	move_and_slide()

	if Input.is_action_just_pressed("attack") && alive && can_control && cd <= 0.0:
		perform_attack()

# Called when an event where the player would take damage would happen
func take_damage(amount: int, global_pos: Vector2 = Vector2.INF) -> void:
	if health != 0: $Ouch.play()
	health = max(health - amount, 0)
	emit_signal("health_changed", health, max_health)
	print("Player HP:", health)
	$AnimationPlayer.play("hit_flash")
	$AnimationPlayer.queue("RESET")
	_knockback(global_pos)
	if health == 0:
		die()

func _knockback(from_global_pos: Vector2) -> void:
	var dir_x := 0.0
	if from_global_pos != Vector2.INF:
		dir_x = sign(global_position.x - from_global_pos.x)
		if dir_x == 0:
			dir_x = 1.0
	else:
		# fallback: push opposite current facing/motion
		dir_x = (velocity.x >= 0.0) if -1.0 else 1.0

	velocity.x = knockback_force * dir_x
	velocity.y = -knockup_force

	# brief stun
	can_control = false
	# fire-and-forget coroutine
	_stun_recover()
	
func _stun_recover() -> void:
	await get_tree().create_timer(hurt_stun).timeout
	if alive:
		can_control = true

func set_checkpoint(pos: Vector2) -> void:
	_checkpoint = pos

func die() -> void:
	$AnimatedSprite2D.play("death")
	alive = false
	print("Player died!")
	await get_tree().create_timer(3.0).timeout
	dead.emit()

func respawn() -> void:
	# move to checkpoint and restore state
	global_position = _checkpoint
	velocity = Vector2.ZERO
	health = max_health
	emit_signal("health_changed", health, max_health)
	alive = true
	can_control = true
	$AnimatedSprite2D.play("default")

# Attacking
func perform_attack() -> void:
	cd = attack_cooldown
	$AnimatedSprite2D.play("parry")
	print("Swing!")
	$Swing.play()
	for body in $SwingRange.get_overlapping_bodies():
		if body.is_in_group("Enemy"):
			if body.has_method("take_damage"):
				body.take_damage(1)
				$SwingHit.play()
	for area in $SwingRange.get_overlapping_areas():
		if area.is_in_group("Projectile") and area.has_method("parry_from"):
			print("PARRIED prot!")
			area.parry_from(global_position)
			$ParryHit.play()
	await get_tree().create_timer(0.3).timeout
	$AnimatedSprite2D.play("default")
	
