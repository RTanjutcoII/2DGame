extends Node2D

@onready var first_cam : Camera2D = $FirstCam
@onready var second_cam : Camera2D = $SecondCam
@onready var prime_cam : Camera2D = $Cam0
@onready var first_guy = $Enemy
@onready var protag = $Protag
@onready var cannon = $Cannon

signal lower_barrier
signal lower_cannonwall

func _ready() -> void:
	prime_cam.enabled = true
	prime_cam.make_current()
	
	first_guy.defeated.connect(_on_first_guy_death)
	protag.dead.connect(_on_player_death)
	cannon.death.connect(_on_cannon_death)
	
func _on_player_death() -> void:
	protag.respawn()
	
func _on_first_guy_death() -> void:
	lower_barrier.emit()

func _switch_camera(new_cam: Camera2D) -> void:
	var old_cam := get_viewport().get_camera_2d()
	if old_cam == new_cam:
		return
	# enable new, disable old, and make new current
	if old_cam: old_cam.enabled = false
	new_cam.enabled = true
	new_cam.make_current()

func _on_cannon_death() -> void:
	lower_cannonwall.emit()
