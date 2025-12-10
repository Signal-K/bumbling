extends CharacterBody2D

var direction: Vector2
var speed := 50

var can_move: bool = true

@onready var move_state_machine = $Animation/AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var tool_state_machine = $Animation/AnimationTree.get("parameters/ToolStateMachine/playback")

var current_tool: Enums.Tool
var current_seed: Enums.Seed

signal tool_use(tool: Enums.Tool, pos: Vector2)

func _physics_process(delta: float) -> void:
	if can_move:
		get_basic_inputs()
		move()
		animate()
	
func get_basic_inputs():
	if Input.is_action_just_pressed("tool_forward") or Input.is_action_just_pressed("tool_backward"):
		var dir = Input.get_axis("tool_backward", "tool_forward")
		current_tool = posmod(current_tool + int(dir), Enums.Tool.size()) as Enums.Tool
	
	if Input.is_action_just_pressed("seed_forward"):
		current_seed = posmod(current_seed + 1, Enums.Seed.size()) as Enums.Seed
	
	if Input.is_action_just_pressed("action"):
		tool_state_machine.travel(Data.TOOL_STATE_ANIMATIONS[current_tool])
		$Animation/AnimationTree.set("parameters/ToolOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		tool_use.emit(current_tool, position)

func move():
	# Check for touch controls
	var touch_controls = get_tree().get_first_node_in_group("touch_controls")
	if touch_controls and touch_controls.get_joystick_vector().length() > 0:
		direction = touch_controls.get_joystick_vector()
	else:
		direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = direction * speed
	move_and_slide()
	
func animate():
	if direction:
		move_state_machine.travel('Walk')
		var direction_animation = Vector2(round(direction.x), round(direction.y))
		$Animation/AnimationTree.set('parameters/MoveStateMachine/Idle/blend_position', direction_animation)
		$Animation/AnimationTree.set('parameters/MoveStateMachine/Walk/blend_position', direction_animation)
		for animation in Data.TOOL_STATE_ANIMATIONS.values():
			var animation_name: String = "parameters/ToolStateMachine/" + animation +  "/blend_position"
			$Animation/AnimationTree.set(animation_name, direction_animation)
	else:
		move_state_machine.travel('Idle')

func tool_use_emit():
	pass

func _on_animation_tree_animation_started(_anim_name: StringName) -> void:
	can_move = false
	
func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	can_move = true
