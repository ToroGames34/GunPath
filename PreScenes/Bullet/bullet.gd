extends Area2D


@onready var Anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var CollShape: CollisionShape2D = $CollisionShape2D
@onready var AudioHit: AudioStreamPlayer = $AudioHit

var Velocity: float = 2050 # Before 930
var Damage: float
var Impact: bool = false


func _ready():
	pass


func _process(delta):
	if !Impact:
		position += transform.y * Velocity * -1 * delta


func ImpactF():
	Impact = true
	Anim.scale = Vector2(1.3, 1.3)
	Anim.play("impact")
	@warning_ignore("incompatible_ternary")
	#AudioHit.play() if GlobalV.CanPlaySounds else ""
	CollShape.set_deferred("disabled", true)


func _on_body_entered(body):
	if body.is_in_group("enemy"):
		ImpactF()
		body.Hurt(roundi(Damage))
	elif body.is_in_group("wall"):
		ImpactF()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_animated_sprite_2d_animation_finished():
	queue_free()
