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
		print("ACTION pressed! Current tool: ", current_tool)
		tool_state_machine.travel(Data.TOOL_STATE_ANIMATIONS[current_tool])
		$Animation/AnimationTree.set("parameters/ToolOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		# Calculate the target tile position based on facing direction
		var blend_pos = $Animation/AnimationTree.get("parameters/MoveStateMachine/Idle/blend_position")
		var facing_direction = Vector2(
			round(blend_pos.x),
			round(blend_pos.y)
		)
		# Default to down if not moving
		if facing_direction == Vector2.ZERO:
			facing_direction = Vector2(0, 1)
		var target_pos = position + facing_direction * Data.TILE_SIZE
		print("Emitting tool_use signal: tool=", current_tool, " blend_pos=", blend_pos, " facing=", facing_direction, " target_pos=", target_pos, " player_pos=", position)
		tool_use.emit(current_tool, target_pos)

func move():
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
