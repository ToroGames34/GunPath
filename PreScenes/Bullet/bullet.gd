extends Area2D


@onready var Anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var CollShape: CollisionShape2D = $CollisionShape2D
@onready var AudioHit: AudioStreamPlayer = $AudioHit

var Velocity: float = 2050 # Before 930
var Damage: float
var Impact: bool = false


func _ready():
	pass


#func _process(delta):
	#if !Impact:
		#position += transform.y * Velocity * -1 * delta



func _process(delta):
	if Impact:
		return

	var from = global_position
	var to = from + transform.y * Velocity * -1 * delta

	var space_state = get_world_2d().direct_space_state

	var params := PhysicsRayQueryParameters2D.create(from, to)
	params.exclude = [self]

	var hit = space_state.intersect_ray(params)

	global_position = hit.position if hit else to


func ImpactF():
	Impact = true
	Anim.scale = Vector2(0.85, 0.85)
	Anim.play("impact")
	@warning_ignore("incompatible_ternary")
	#AudioHit.play() if GlobalV.CanPlaySounds else ""
	CollShape.set_deferred("disabled", true)


func _on_body_entered(body):
	if body.is_in_group("player"):
		ImpactF()
		body.TakeDamage(roundi(Damage))
	elif body.is_in_group("enemy"):
		ImpactF()
		body.TakeDamage(roundi(Damage))
	elif body.is_in_group("wall"):
		ImpactF()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_animated_sprite_2d_animation_finished():
	queue_free()
