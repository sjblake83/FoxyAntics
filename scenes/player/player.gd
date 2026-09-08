class_name Player
extends CharacterBody2D

const GROUP_NAME: String = "player"

const FLASH_COUNT: int = 6
const FLASH_DURATION: float = 0.2
const GRAVITY: float = 690.0
const MAX_FALL_SPEED: float = 300.0
const RUN_SPEED: float = 100.0
const JUMP_SPEED: float = -280.0
const STOMP_SPEED: float = -200.0
const HURT_VELOCITY: Vector2 = Vector2(0.0, -180.0)


@export var camera_left: int = -10000
@export var camera_right: int = 10000
@export var camera_top: int = -10000
@export var camera_bottom: int = 10000

@onready var player_cam: Camera2D = $PlayerCam
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var hit_area: Area2D = $HitArea
@onready var stomp_area: Area2D = $StompArea

@onready var jump_sound: AudioStreamPlayer = $Sounds/JumpSound
@onready var land_sound: AudioStreamPlayer = $Sounds/LandSound
@onready var death_sound: AudioStreamPlayer = $Sounds/DeathSound
@onready var hurt_sound: AudioStreamPlayer = $Sounds/HurtSound

@onready var hurt_timer: Timer = $HurtTimer


var is_still: bool:
	get: return is_zero_approx(velocity.x)
var is_falling: bool:
	get: return velocity.y > 0
var is_ground: bool:
	get: return is_on_floor()
var is_hurt: bool:
	get: return _is_hurt


var _jumping: bool = false
var _was_on_floor: bool = false
var _start_position: Vector2
var _is_hurt: bool = false
var _is_invincible: bool = false
var _invincible_tween: Tween
var _damage_areas: Array[Area2D]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		_jumping = true
		jump_sound.play()

func _enter_tree() -> void:
	add_to_group(GROUP_NAME)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start_position = position
	set_camera_limits()


func set_camera_limits() -> void:
	player_cam.limit_left = camera_left
	player_cam.limit_right = camera_right
	player_cam.limit_top = camera_top
	player_cam.limit_bottom = camera_bottom


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	flip_sprite()
	move_and_slide()
	check_landed()


func flip_sprite() -> void:
	var direction: float = Input.get_axis("left", "right")
	if is_zero_approx(direction):
		return
	sprite_2d.flip_h = direction < 0


func check_landed() -> void:
	var _on_floor: bool = is_on_floor()
	if not _was_on_floor and _on_floor:
		land_sound.play()
	_was_on_floor = _on_floor


func handle_movement(delta: float) -> void:
	if !is_hurt:
		velocity.x = Input.get_axis("left", "right") * RUN_SPEED
	if _jumping:
		velocity.y = JUMP_SPEED
		_jumping = false
	else:
		velocity.y += GRAVITY * delta
	velocity.y = minf(velocity.y, MAX_FALL_SPEED)


func fell_off() -> void:
	set_position.call_deferred(_start_position)
	velocity = Vector2(0, 100)
	death_sound.play()


func go_invincible() -> void:
	if _is_invincible: return
	_is_invincible = true
	if _invincible_tween and _invincible_tween.is_running():
		_invincible_tween.kill()
	_invincible_tween = create_tween()
	_invincible_tween.set_loops(FLASH_COUNT)
	_invincible_tween.tween_property(sprite_2d, "modulate", Color.TRANSPARENT, FLASH_DURATION)
	_invincible_tween.tween_property(sprite_2d, "modulate", Color.WHITE, FLASH_DURATION)
	_invincible_tween.finished.connect(invincible_finished)


func invincible_finished() -> void:
	_is_invincible = false
	if _damage_areas.size() > 0:
		apply_hit.call_deferred()


func apply_hurt_jump() -> void:
	if !_is_hurt:
		_is_hurt = true
		hurt_timer.start()
		velocity = HURT_VELOCITY
		hurt_sound.play()


func apply_hit() -> void:
	if _is_invincible: return
	apply_hurt_jump()
	go_invincible()


func apply_stomp() -> void:
	velocity.y = STOMP_SPEED

func apply_bounce(bounce_velocity: Vector2) -> void:
	velocity = bounce_velocity

func _on_hurt_timer_timeout() -> void:
	_is_hurt = false


func _on_hit_area_area_entered(area: Area2D) -> void:
	apply_hit.call_deferred()
	if area not in _damage_areas:
		_damage_areas.append(area)


func _on_hit_area_area_exited(area: Area2D) -> void:
	_damage_areas.erase(area)


func _on_stomp_area_area_entered(area: Area2D) -> void:
	if velocity.y < 0 or _is_hurt: return
	if area is StompBox and not area.is_hit:
		apply_stomp.call_deferred()
		area.trigger()
	if area is Trampoline:
		apply_bounce.call_deferred(area.bounce_velocity)
		area.bounce()
