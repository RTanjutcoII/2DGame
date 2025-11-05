extends CanvasLayer

@export var player: NodePath
@onready var hp_label: Label = $HPLabel

func _ready():
	var player_node = get_node(player)
	player_node.health_changed.connect(_on_health_changed)
	_on_health_changed(player_node.health, player_node.max_health)

func _on_health_changed(current, max):
	hp_label.text = "HP: %d / %d" % [current, max]
