extends CharacterBody2D

enum playerstate{
	idle,
	walk,
	jump,
	duck,
	slide,
	dead
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var reload_timer: Timer = $ReloadTimer


@export var max_speed = 100.0
@export var acceletration = 400
@export var deceletration = 400
@export var slide_deceleration = 100
const JUMP_VELOCITY = -300.0

var jump_count = 0 
@export var max_jump_count = 2     
var direction = 0 
var status: playerstate



func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		
	match status:
		playerstate.idle:
			idle_state(delta)
		playerstate.walk:
			walk_state(delta)
		playerstate.jump:
			jump_state(delta)
		playerstate.duck:
			duck_state(delta)
		playerstate.slide:
			slide_state(delta)
		playerstate.dead:
			dead_state(delta)
	move_and_slide()

func go_to_idle_state():
	status = playerstate.idle
	anim.play("idle")
	
func go_to_walk_state():
	status = playerstate.walk
	anim.play("walk")
	
func go_to_jump_state():
	status = playerstate.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1
func go_to_duck_state():
	status = playerstate.duck
	anim.play("duck")
	set_small_collider()
	
func exit_from_duck_state():
	set_large_collider()
	
	
func go_to_slide_state():
	status = playerstate.slide
	anim.play("slide") 
	set_small_collider()

func exit_from_slide_state():
	set_large_collider()
	
func go_to_dead_state():
	if status ==playerstate.dead:
		return
		
	status=playerstate.dead
	anim.play("dead")
	velocity.x =0
	reload_timer.start()
	
	

func idle_state(delta):
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

func walk_state(delta):
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_just_pressed("duck"):
		go_to_slide_state()
		return


func jump_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && jump_count < max_jump_count:
		go_to_jump_state()
	
	if is_on_floor():
		jump_count = 0 
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func duck_state(_delta):
	update_direction()
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return

func slide_state(delta):
	velocity.x = move_toward(velocity.x, 0,slide_deceleration * delta)
	
	if Input.is_action_just_released("duck"):
		exit_from_slide_state()
		go_to_walk_state()
		return
		
	if velocity.x == 0:
		exit_from_slide_state()
		go_to_duck_state()
		return
		
func dead_state(_delta):
	velocity.x = 0  # Garante que o player não se mexa
	# Não troca de cena aqui mais

func move(delta):
	update_direction()
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceletration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceletration * delta)

func update_direction():
	direction = Input.get_axis("left", "right")

	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

func set_small_collider():
	collision_shape_2d.shape.radius = 5
	collision_shape_2d.shape.height = 10
	collision_shape_2d.position.y = 3
	
	
	hitbox_collision_shape.shape.size.y = 10
	hitbox_collision_shape.position.y = 3
	
func set_large_collider():
	collision_shape_2d.shape.radius = 6
	collision_shape_2d.shape.height = 16
	collision_shape_2d.position.y = 0
	
	hitbox_collision_shape.shape.size.y = 15
	hitbox_collision_shape.position.y = 0.5

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("lethal_area"):
		hit_lethal_area()
		
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("lethal_area"):
		go_to_dead_state()
	
func hit_enemy(area:Area2D):
	if velocity.y > 0:
		#inimigo morre
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		#player morre
		
			go_to_dead_state()
			


func hit_lethal_area():
	go_to_dead_state()
	
func _on_reload_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scene/game_over.tscn")
