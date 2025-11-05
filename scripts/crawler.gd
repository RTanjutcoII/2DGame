extends CharacterBody2D

@export var health : int = 1
@export var speed : float = 250
@export var player: NodePath
@export var active = false
@export var trigger: NodePath

var _spawned : bool = false
var _moving : bool = false
var _dir := -1  # start moving left

signal defeated

func _ready() -> void:
	if !active:
		$Area2D/Hurtbox.disabled = true
		$AnimatedSprite2D.visible = false
		$Hitbox.disabled = true
	else:
		_spawn_in()
		
	if trigger != NodePath():
		var trig = get_node(trigger)
		if trig and trig.has_signal("defeated"):
			trig.connect("defeated", self.activate)
		elif trig and trig.has_signal("spawned"):
			trig.connect("spawned", self.activate)
	
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.take_damage(1, global_position)

func activate() -> void:
	if active: return
	active = true
	_spawn_in()

func _spawn_in() -> void:
	if _spawned: return
	_spawned = true

	$AnimatedSprite2D.visible = true	
	$AnimatedSprite2D.play("spawn")
	await $AnimatedSprite2D.animation_finished

	# Enable collisions after spawn anim
	$Area2D/Hurtbox.disabled = false
	$Hitbox.disabled = false

	# Start moving state
	_moving = true
	$AnimatedSprite2D.play("move")
	
func _physics_process(delta: float) -> void:
	if !_moving: 
		return

	# Move
	velocity.x = speed * _dir
	move_and_slide()

	# Flip sprite based on direction
	$AnimatedSprite2D.flip_h = (_dir > 0)

	# Turn around when hitting wall
	if is_on_wall():
		_dir *= -1
		
func take_damage(amount: int) -> void:
	health -= amount
	$AnimationPlayer.play("hit_flash")
	$AnimationPlayer.queue("RESET")
	if health <= 0:
		die()
		
func die() -> void:
	defeated.emit()
	queue_free()
