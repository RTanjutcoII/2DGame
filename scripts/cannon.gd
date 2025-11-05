# cannon.gd
extends Node2D

@export var bomb_scene: PackedScene
@export var fire_interval: float = 2.0
@export var fire_frame: int = 3    
@export_enum("Right", "Left") var shoot_dir: int = 1   

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn_marker: Node2D  = $SpawnMarker
@onready var detection_area: Area2D = $DetectionArea

signal death

var _player_in_range := false
var _loop_running := false
var _armed := false   # only spawn once per fire animation

func _ready() -> void:
	add_to_group("Enemy")
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	sprite.frame_changed.connect(_on_frame_changed)
	$Kaboom.visible = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		_player_in_range = true
		if not _loop_running:
			_loop_running = true
			_fire_loop()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		_player_in_range = false

func _fire_loop() -> void:
	while _player_in_range:
		# arm one shot and play the fire animation
		_armed = true
		sprite.play("fire")
		# wait out the cooldown
		await get_tree().create_timer(fire_interval).timeout
	# left range → stop loop
	_loop_running = false

func _on_frame_changed() -> void:
	# spawn exactly on the requested frame, once per fire animation
	if _armed and sprite.animation == "fire" and sprite.frame == fire_frame:
		_spawn_bomb()
		_armed = false

func _spawn_bomb() -> void:

	var bomb := bomb_scene.instantiate()
	get_tree().current_scene.add_child(bomb)

	# Spawn position (no ternary)
	var spawn_pos: Vector2 = global_position
	if spawn_marker != null:
		spawn_pos = spawn_marker.global_position
	bomb.global_position = spawn_pos

	# Direction (no ternary) — default Left
	var dir: Vector2 = Vector2.LEFT
	if shoot_dir == 0:
		dir = Vector2.RIGHT

	# Hand off to bomb without type warnings
	bomb.set("_direction", dir)
	bomb.set("_owner", "enemy")
	bomb.set("_life_timer", bomb.get("lifetime"))
	
func take_damage_cannonball(dmg:int = 1) -> void:
	# Stop firing and collisions immediately
	_player_in_range = false
	detection_area.monitoring = false
	$CollisionShape2D.set_deferred("disabled", true)

	# Swap to explosion
	sprite.visible = false
	$Kaboom.visible = true
	$Kaboom.play("Kaboom")
	await $Kaboom.animation_finished   # don't check a specific frame
	death.emit()
	queue_free()
