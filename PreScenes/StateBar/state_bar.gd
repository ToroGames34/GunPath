@tool
extends Control


const MAX_VALUE: int = 100

signal FullBarWithTime
signal EmptyBar
signal ChangeVal

@export_category("Style Bar")
@export var ScaleBar: Vector2 = Vector2(1, 1)
@export var BarColor: Color = Color(1, 1, 1)
@export var EnableIconBar: bool = true
@export var IconBar: Resource = null
@export var ShowValues: bool = true
@export var AllowDamageIndicator: bool = true
@export var DamageIndicatorBarColor: Color = Color(1, 1, 1)

@export_category("Confg Bar")
@export_enum ("Health", "Mana", "Dash") var ModeBar: String
@export var AllowRegeneration: bool = true
@export var DelayRegenAfterDamage: float = 1.0
@export var RegenerationPerStep: float = 1.0
##If you want to change the max value must be via script changing const "MAX_VALUE"
@export_range(0, MAX_VALUE) var MaxValue: int = 100
@export_range(0, MAX_VALUE) var CurrentValue: int = 50

@export_category("Confg Bar With Time")
@export var FillBarWithTime: bool = false
@export var TimeToFillBar: float = 1
@export var DelayToFillWithTime: float = 0.0
@export var ConserveLastBarValue: bool = true
@export var BarColorFullWithTime: Color = Color(1, 1, 1)


@onready var ProgressBarV: TextureProgressBar = $TextureProgressBar
@onready var BarDmgIndicator: TextureProgressBar = $BarDmgIndicator
@onready var LabelValue: Label = $LabelValue
@onready var LabelMaxVal: Label = $LabelMaxVal
@onready var IconBarNode: TextureRect = $TexIconBar
@onready var LabelSeparator: Label = $LabelSeparator
@onready var LabelRegenSpeed: Label = $LabelRegenContainer/LabelRegenSpeed
@onready var EffectContainer: Node2D = $EffectContainer
@onready var BorderIconBar: TextureRect = $BorderIconBar
@onready var ColorBgBar: ColorRect = $ColorBgBar
@onready var LabelRegenContainer: Control = $LabelRegenContainer
#@onready var music_and_sound_manager: Node = $MusicAndSoundManager

var TimerRefill: Timer = Timer.new()
var TimerDelayFillWithTime: Timer = Timer.new()
var TweenFillWithTime: Tween
var SpeedUpdateDmgIndicator: float = 0.5
var OneTimeRunTimerRefill: bool = true
var IsFillingWithTime: bool = false
var CanUpdateDmgIndicator: bool = true
var IsTweenFillWithTimeAlive: bool = false
var OneTimeShootAfterPause: bool = false
var CanUpdate: bool = false
var StartFillWithTime: bool = false
var OneTimeDelayFillWithTime: bool = true
var CanContinueRegenerating: bool = true


func _ready():
	IconBarNode.texture = IconBar
	ProgressBarV.modulate = BarColor
	BarDmgIndicator.modulate = DamageIndicatorBarColor
	LabelRegenSpeed.visible = false
	SetValueRegeneration(RegenerationPerStep)
	SetColorToLabels(Color(1, 1, 1))
	SetMaxValue(MaxValue)
	SetValue(CurrentValue)
	UpdateInfoLabels()
	TimerRefillSettings()
	TimerDelayFillWithTimeSettings()
	CheckForNoInconsistencies()
	CheckForEnableIconBar(EnableIconBar)
	CheckForLabelsInfoVisible()
	ChangeScaleBar(ScaleBar)
	CheckForDmgIndicator(AllowDamageIndicator)
	FillBarWithTimeInit()
	CanUpdate = true


func CheckForNoInconsistencies() -> void:
	if ModeBar.is_empty():
		assert(false, "A mode needs to be set!")
	
	if AllowRegeneration and FillBarWithTime:
		assert(false, "You can't have Regen and FillWithTime at the same time!")


func CheckForEnableIconBar(val: bool) -> void:
	IconBarNode.visible = val
	BorderIconBar.visible = val


func CheckForDmgIndicator(val: bool) -> void:
	BarDmgIndicator.visible = val


func ChangeScaleBar(val: Vector2) -> void:
	scale = val
	#LabelRegenContainer.scale.x = val.x
	#ProgressBarV.scale = val
	#LabelValue.scale = val
	#LabelMaxVal.scale = val
	#LabelSeparator.scale = val
	#LabelRegenSpeed.scale = val
	#ColorBgBar.scale = val
	#BarDmgIndicator.scale = val
	#
	#if ModeBar == "Dash" and ScaleBar != Vector2(1, 1):
		#ColorBgBar.size.x += 25


func CheckForLabelsInfoVisible() -> void:
	SetVisibilityLabels(ShowValues)


func TimerRefillSettings() -> void:
	TimerRefill.wait_time = 1
	TimerRefill.connect("timeout", self._on_TimerRefill_timeout)
	add_child(TimerRefill)


func TimerDelayFillWithTimeSettings() -> void:
	if DelayToFillWithTime <= 0.0:
		DelayToFillWithTime = 0.001
	TimerDelayFillWithTime.wait_time = DelayToFillWithTime
	TimerDelayFillWithTime.one_shot = true
	TimerDelayFillWithTime.connect("timeout", self._on_TimerDelayFillWithTime_timeout)
	add_child(TimerDelayFillWithTime)


@warning_ignore("unused_parameter")
func _process(delta) -> void:
	if !get_tree().paused:
		RefillMaganer()
		UpdateInfoLabels()
		UpdateDmgIndicatorBar()
		ShootAfterPause()
	else:
		PauseF()
	
	if FillBarWithTime:
		CheckWhenIsPauseForFillWithTime()
	
	# Code to execute in editor.
	if Engine.is_editor_hint():
		IconBarNode.texture = IconBar
		ProgressBarV.modulate = BarColor
		LabelRegenSpeed.visible = false
		SetColorToLabels(Color(1, 1, 1))
		SetMaxValue(MaxValue)
		SetValue(CurrentValue)
		UpdateInfoLabels()
		CheckForEnableIconBar(EnableIconBar)
		CheckForLabelsInfoVisible()
		ChangeScaleBar(ScaleBar)


func UpdateInfoLabels() -> void:
	LabelValue.text = str(int(ProgressBarV.value))
	LabelMaxVal.text = str(int(ProgressBarV.max_value))
	LabelRegenSpeed.text = "+" + str(RegenerationPerStep)


func SetColorToLabels(clrs: Color) -> void:
	LabelValue.modulate = clrs
	LabelMaxVal.modulate = clrs
	LabelSeparator.modulate = clrs
	LabelRegenSpeed.modulate = clrs


func SetVisibilityLabels(val: bool) -> void:
	LabelValue.visible = val
	LabelMaxVal.visible = val
	LabelSeparator.visible = val
	LabelRegenSpeed.visible = val


func SetMaxValue(value: int) -> void:
	ProgressBarV.max_value = value
	BarDmgIndicator.max_value = value


func IncreaseMaxValue(value: int) -> void:
	ProgressBarV.max_value += value
	BarDmgIndicator.max_value += value


func SetValue(value: int) -> void:
	ProgressBarV.value = value


func SetIncreaseValue(value: int) -> void:
	ProgressBarV.value += value


func SetDecreaseValue(value: int) -> void:
	ProgressBarV.value -= value
	UpdateDmgIndicator()
	
	CanContinueRegenerating = false
	TimerRefill.stop()
	await get_tree().create_timer(DelayRegenAfterDamage).timeout
	OneTimeRunTimerRefill = true
	CanContinueRegenerating = true
	
	#music_and_sound_manager.SoundHitMelee(1)


func GetValue() -> int:
	return ProgressBarV.value


func GetMaxValue() -> int:
	return ProgressBarV.max_value


func SetValueRegeneration(val: float) -> void:
	ProgressBarV.step = val


func IncreaseValueRegeneration(val: float) -> void:
	ProgressBarV.step += val
	RegenerationPerStep += val


func DecreaseValueRegeneration(val: float) -> void:
	ProgressBarV.step -= val
	RegenerationPerStep -= val


func _on_TimerRefill_timeout() -> void:
	SetIncreaseValue(RegenerationPerStep)


func RefillMaganer() -> void:
	if AllowRegeneration:
		if CanContinueRegenerating:
			if ProgressBarV.value < ProgressBarV.max_value:
				if OneTimeRunTimerRefill:
					OneTimeRunTimerRefill = false
					TimerRefill.start()
					SetRegenLabelShow(true)
			else:
				TimerRefill.stop()
				OneTimeRunTimerRefill = true
				SetRegenLabelShow(false)
	else:
		SetRegenLabelShow(false)
		TimerRefill.stop()


func _on_texture_progress_bar_value_changed(value) -> void:
	if value <= 0:
		emit_signal("EmptyBar")
	if CanUpdate:
		emit_signal("ChangeVal")


func GetModeBar() -> String:
	return ModeBar


func SetAllowRegeneration(val: bool) -> void:
	AllowRegeneration = val
	OneTimeRunTimerRefill = true
	RefillMaganer()


func GetAllowRegeneration() -> bool:
	return AllowRegeneration


func SetRegenLabelShow(val: bool) -> void:
	if ShowValues:
		LabelRegenSpeed.visible = val


func CheckWhenIsPauseForFillWithTime() -> void:
	if TweenFillWithTime != null and IsTweenFillWithTimeAlive:
		if ProgressBarV.value != GetMaxValue():
			if get_tree().paused:
				TweenFillWithTime.pause()
			#else:
				#TweenFillWithTime.play()


func StartBarWithTime() -> void:#Use this for the bar with time
	if !ConserveLastBarValue:
		SetValue(0)
		StartBarWithTime_Delay()
	else:
		StartBarWithTime_Delay()


func FillBarWithTimeInit() -> void:
	if FillBarWithTime:
		if ProgressBarV.value < ProgressBarV.max_value:
			StartBarWithTime()


func SetDecreaseValueFillWithTime(value: int) -> void:
	if TweenFillWithTime != null and TweenFillWithTime.is_running():
		TweenFillWithTime.stop()
	ProgressBarV.value -= value
	if AllowDamageIndicator:
		UpdateDmgIndicator()
	StartBarWithTime()


func StartBarWithTime_Delay() -> void:
	TimerDelayFillWithTime.start()


func _on_TimerDelayFillWithTime_timeout() -> void:
	FillBarOnTime(TimeToFillBar)


func SetTimeToFillBar(val: float) -> void:
	TimeToFillBar = val


func FillBarOnTime(val: float) -> void:
	TweenFillWithTime = create_tween()
	
	ProgressBarV.modulate = BarColor
	IsFillingWithTime = true
	IsTweenFillWithTimeAlive = true
	
	TweenFillWithTime.tween_property(ProgressBarV, "value", GetMaxValue(), val)
	
	await TweenFillWithTime.finished
	
	if FillBarWithTime:
		ProgressBarV.modulate = BarColorFullWithTime
		emit_signal("FullBarWithTime")
		IsFillingWithTime = false
		IsTweenFillWithTimeAlive = false


func UpdateDmgIndicator() -> void:
	var tween: Tween = create_tween()
	
	CanUpdateDmgIndicator = false
	
	tween.tween_property(BarDmgIndicator, "value", ProgressBarV.value, 
		SpeedUpdateDmgIndicator).set_trans(Tween.TRANS_LINEAR)
	
	await tween.finished
	CanUpdateDmgIndicator = true


func UpdateDmgIndicatorBar() -> void:
	if CanUpdateDmgIndicator and AllowDamageIndicator:
		BarDmgIndicator.value = snapped(ProgressBarV.value, 0)


func PauseF() -> void:
	TimerRefill.stop()
	
	if IsTweenFillWithTimeAlive:
		IsTweenFillWithTimeAlive = false
		TweenFillWithTime.pause()
	
	OneTimeShootAfterPause = true
	OneTimeRunTimerRefill = true
	IsFillingWithTime = false
	CanUpdateDmgIndicator= true


func ShootAfterPause() -> void:
	if OneTimeShootAfterPause:
		OneTimeShootAfterPause = false
	
		if FillBarWithTime:
			if !IsFillingWithTime and GetValue() != GetMaxValue():
				TweenFillWithTime.play()
