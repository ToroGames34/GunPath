extends CharacterBody2D


@onready var bullet = preload("res://PreScenes/Bullet/bullet.tscn")

signal ShootBullets(bullet, pos, rot, dmg)

@onready var BodyPart: Node2D = $BodyPart
@onready var FusilSprite: Sprite2D = $BodyPart/Cont/WeaponContainer/Fusil
@onready var ShotgunSprite: Sprite2D = $BodyPart/Cont/WeaponContainer/Shotgun

var TimerAttackSpeed: Timer = Timer.new()
var Weapons: Array = ["fusil", "shotgun"]
var WeaponsUsing: String = ""

var Speed: float = 220.0
var Health: float = 100.0
var Acceleration: float = 50.0

var AttackSpeedFusil: float = 0.05
var AttackSpeedShotGun: float = 0.35

var DamageFusil: float = 35
var DamageShotGun: float = 35

var TotalScatteringSpread = 15.0  # total degrees of dispersion | Before 30.0
var NumOfShots: int = 5

var AttackSpeedGeneral: float
var DamageGeneral: float

var IsDeath: bool = false
var IsMoving: bool = false
var CanShoot: bool = true
var CanShootCD: bool = true
var CanScattering: bool = false


func _ready() -> void:
	WeaponsUsing = Weapons[0]
	SetWeaponAtribute()
	TimerAttackSpeedSetting()


func TimerAttackSpeedSetting() -> void:
	TimerAttackSpeed.wait_time = AttackSpeedGeneral
	TimerAttackSpeed.one_shot = true
	TimerAttackSpeed.autostart = false
	TimerAttackSpeed.connect("timeout", self._on_TimerAttackSpeed_timeout)
	add_child(TimerAttackSpeed)


func SetWeaponAtribute():
	match WeaponsUsing:
		"fusil":
			WeaponsUsing = Weapons[0]
			AttackSpeedGeneral = AttackSpeedFusil
			DamageGeneral = DamageFusil
			TimerAttackSpeed.wait_time = AttackSpeedGeneral
			CanScattering = false
		"shotgun":
			WeaponsUsing = Weapons[1]
			AttackSpeedGeneral = AttackSpeedShotGun
			DamageGeneral = DamageShotGun
			TimerAttackSpeed.wait_time = AttackSpeedGeneral
			CanScattering = true


func _process(delta: float) -> void:
	if !IsDeath:
		AimWeapons()
		ChangeWeapon()
		ShootWeapons()


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


func ChangeWeapon():
	if Input.is_action_just_pressed("1"):
		WeaponsUsing = Weapons[0]
		FusilSprite.visible = true
		ShotgunSprite.visible = false
		SetWeaponAtribute()
	elif Input.is_action_just_pressed("2"):
		WeaponsUsing = Weapons[1]
		FusilSprite.visible = false
		ShotgunSprite.visible = true
		SetWeaponAtribute()


func ShootWeapons():
	match WeaponsUsing:
		"fusil":
			if Input.is_action_pressed("left_click") and CanShoot and CanShootCD:
				CanShootCD = false
				TimerAttackSpeed.start()
				
				if !CanScattering:
					emit_signal("ShootBullets", bullet, BodyPart.get_node("Marker2D").global_position, BodyPart.rotation_degrees + 90, DamageGeneral)
				else:
					var middle_rotation = BodyPart.rotation_degrees + 90
					var angle_step = 0.0
					
					if NumOfShots > 1:
						angle_step = TotalScatteringSpread / (NumOfShots - 1)
					
					var start_angle = middle_rotation - (TotalScatteringSpread / 2.0)
					
					for i in range(NumOfShots):
						var current_angle = start_angle + (angle_step * i)
						emit_signal("ShootBullets", bullet, BodyPart.get_node("Marker2D").global_position, current_angle, DamageGeneral)
		"shotgun":
			if Input.is_action_just_pressed("left_click") and CanShoot and CanShootCD:
				CanShootCD = false
				TimerAttackSpeed.start()
				
				if !CanScattering:
					emit_signal("ShootBullets", bullet, BodyPart.get_node("Marker2D").global_position, BodyPart.rotation_degrees + 90, DamageGeneral)
				else:
					var middle_rotation = BodyPart.rotation_degrees + 90
					var angle_step = 0.0
					
					if NumOfShots > 1:
						angle_step = TotalScatteringSpread / (NumOfShots - 1)
					
					var start_angle = middle_rotation - (TotalScatteringSpread / 2.0)
					
					for i in range(NumOfShots):
						var current_angle = start_angle + (angle_step * i)
						emit_signal("ShootBullets", bullet, BodyPart.get_node("Marker2D").global_position, current_angle, DamageGeneral)


func BulletInts() -> void:
	var Bullet = bullet.instantiate()
	Bullet.global_position = get_node("Marker2D").global_position
	Bullet.rotation_degrees = BodyPart.rotation_degrees + 90
	Bullet.Damage = DamageGeneral
	get_parent().BulletContainer.call_deferred("add_child", Bullet)


func _on_TimerAttackSpeed_timeout() -> void:
	CanShootCD = true
