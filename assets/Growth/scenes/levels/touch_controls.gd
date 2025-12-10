extends CanvasLayer

@onready var joystick_base = $JoystickBase
@onready var joystick_tip = $JoystickBase/JoystickTip
@onready var action_button = $ActionButton

var joystick_active = false
var joystick_touch_index = -1
var joystick_vector = Vector2.ZERO
var joystick_radius = 50

func _ready():
	# Only show on mobile/touch devices
	if not OS.has_feature("mobile"):
		visible = false

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			var touch_pos = event.position
			# Check if touch is on joystick area
			if joystick_base.get_global_rect().has_point(touch_pos):
				joystick_active = true
				joystick_touch_index = event.index
				update_joystick(touch_pos)
		else:
			if event.index == joystick_touch_index:
				joystick_active = false
				joystick_touch_index = -1
				joystick_tip.position = Vector2.ZERO
				joystick_vector = Vector2.ZERO
	
	elif event is InputEventScreenDrag:
		if joystick_active and event.index == joystick_touch_index:
			update_joystick(event.position)

func update_joystick(touch_pos):
	var base_center = joystick_base.global_position + joystick_base.size / 2
	var offset = touch_pos - base_center
	
	if offset.length() > joystick_radius:
		offset = offset.normalized() * joystick_radius
	
	joystick_tip.position = offset
	joystick_vector = offset / joystick_radius

func get_joystick_vector() -> Vector2:
	return joystick_vector

func _on_action_button_pressed():
	# Simulate spacebar press for action
	var press_event = InputEventAction.new()
	press_event.action = "action"
	press_event.pressed = true
	Input.parse_input_event(press_event)

func _on_action_button_released():
	# Simulate spacebar release
	var release_event = InputEventAction.new()
	release_event.action = "action"
	release_event.pressed = false
	Input.parse_input_event(release_event)
