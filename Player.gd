extends CharacterBody2D

@onready var speed = 100
@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D

var is_playing_override_anim = false

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	velocity = input_direction * speed
	move_and_slide()

	# Flip sprite based on direction
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

	# Skip regular animation if one-shot animation is playing
	if is_playing_override_anim:
		return

	# Handle one-shot input actions
	if Input.is_action_just_pressed("attack"):
		play_override_animation("attack")
	elif Input.is_action_just_pressed("jump"):
		play_override_animation("jump")
	elif velocity.length() > 0:
		if anim_player.current_animation != "walk" or !anim_player.is_playing():
			anim_player.play("walk")
	else:
		if anim_player.current_animation != "idle" or !anim_player.is_playing():
			anim_player.play("idle")

func play_override_animation(anim_name: String):
	is_playing_override_anim = true
	anim_player.play(anim_name)

	# Ensure no multiple signal connections
	if anim_player.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		anim_player.disconnect("animation_finished", Callable(self, "_on_animation_finished"))

	anim_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_animation_finished(anim_name: String):
	if anim_name == "attack" or anim_name == "jump":
		is_playing_override_anim = false
