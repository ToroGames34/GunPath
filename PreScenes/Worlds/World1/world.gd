extends Node2D

@onready var BulletContainer: Node2D = $BulletContainer


func _on_player_shoot_bullets(bullet: Variant, pos: Variant, rot: Variant, dmg: Variant) -> void:
	var Bullet = bullet.instantiate()
	Bullet.global_position = pos
	Bullet.rotation_degrees = rot
	Bullet.Damage = dmg
	BulletContainer.call_deferred("add_child", Bullet)
