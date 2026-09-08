extends EnemyBase

enum PigState { WALK, ANGRY }

@export var angry_speed: float = 60.0
@export var angry_timer: float = 5.0

@onready var sight_ray: RayCast2D = $SightRay
@onready var timer: Timer = $Timer

var _state: PigState = PigState.WALK
var _player_ref: Player
var _distance_to_player: float

func _ready() -> void:
	_player_ref = get_tree().get_first_node_in_group(Player.GROUP_NAME)
	if !_player_ref:
		push_error("NO PLAYER FOUND BY PIG")
		queue_free()
		return
	change_state(PigState.WALK)

func _update_behavior(delta: float) -> void:
	match _state:
		PigState.WALK:
			do_walk()
			detect_player()
		PigState.ANGRY:
			do_angry(delta)

func do_angry(delta: float) -> void:
	_distance_to_player = _player_ref.global_position.x - global_position.x
	var stop_threshold = angry_speed * delta + 1.0
	_direction = sign(_distance_to_player)
	if absf(_distance_to_player) <= stop_threshold:
		velocity.x = 0
	else:
		velocity.x = _direction * angry_speed
		flip_sprite()

func flip_raycasts() -> void:
	super()
	sight_ray.target_position.x *= -1

func detect_player() -> void:
	if sight_ray.is_colliding():
		change_state(PigState.ANGRY)

func _align_rays() -> void:
	if sign(wall_ray.target_position.x) != _direction:
		flip_raycasts()

func change_state(new_state: PigState) -> void:
	_state = new_state
	match _state:
		PigState.WALK:
			_align_rays()
			animated_sprite_2d.play("walk")
		PigState.ANGRY:
			animated_sprite_2d.play("run")
			timer.start(angry_timer * randf_range(0.7, 1.2))

func _on_stomp_box_stomped() -> void:
	timer.stop()
	super()

func _on_timer_timeout() -> void:
	if _state == PigState.ANGRY:
		change_state(PigState.WALK)
