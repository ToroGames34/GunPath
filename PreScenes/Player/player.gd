extends CharacterBody2D


@onready var BodyPart: Node2D = $BodyPart

var Speed: float = 220.0
var Health: float = 100.0
var Acceleration: float = 50.0
var IsDeath: bool = false
var IsMoving: bool = false


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	AimWeapons()


func AimWeapons() -> void:
	BodyPart.look_at(get_global_mouse_position())


func _physics_process(delta) -> void:
	if !IsDeath:
		MoveSystem(delta)
		move_and_slide()


func MoveSystem(Delta) -> void:
	var Dir = Vector2()
	Dir.y = Input.get_axis("w", "s")
	Dir.x = Input.get_axis("a", "d")
	
	CheckIsMoving(Dir)
	
	Dir = Dir.normalized()
	velocity = velocity.lerp(Dir * Speed, Acceleration * Delta)


func CheckIsMoving(val: Vector2) -> void:
	if val.x != 0 or val.y != 0:
		IsMoving = true
	else:
		IsMoving = false
