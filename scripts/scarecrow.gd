extends StaticBody2D

func take_damage(_num : int):
	$AnimationPlayer.play("hit_flash")
	$AnimationPlayer.queue("RESET")
