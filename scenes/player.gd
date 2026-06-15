extends CharacterBody2D

@onready var player: CharacterBody2D = $"."

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_sword: AudioStreamPlayer2D = $SwingSword
@onready var hitbox: Area2D = $Hitbox


const SPEED = 300.0

var last_direction : Vector2 = Vector2.RIGHT
var is_attacking : bool = false
var hitbox_offset: Vector2
var strength: int = 20


func _ready() -> void:
	hitbox_offset = hitbox.position

func _physics_process(_delta: float) -> void:
	
	hitbox.monitoring = false
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	
	if is_attacking:
		velocity = Vector2.ZERO
		return
	
	process_movement()
	process_animation()
	move_and_slide()

func process_movement() -> void:
	
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO
	
	

func process_animation() -> void:
	if is_attacking:
		return
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play( prefix + "_right")
		
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")





func attack() -> void:
	is_attacking = true
	hitbox.monitoring = true
	swing_sword.play()
	play_animation("attack", last_direction)
	




func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false




func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	
	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x , y)
		Vector2.RIGHT:
			hitbox.position = Vector2(x , y)
		Vector2.UP:
			hitbox.position = Vector2(y , -x)
		Vector2.DOWN:
			hitbox.position = Vector2(-y , x)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("slime"):
		body.take_damage(strength, position)
