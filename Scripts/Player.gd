extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0
var on_boat = false  # Track if the player is on the boat

# Gravity will be set to 0, as per your preference
var gravity = 0
@onready var parking_zone = $"../ParkingZone"
@onready var boarding_zone = $"../OnBoard"
@onready var animated_sprite = $AnimatedSprite2D
func _ready():
	print("Boarding Zone Position: ", boarding_zone.position)
	print("Parking Zone Position: ", parking_zone.position)
func _physics_process(delta):
	# Check if the player is on the boat or controlling themselves
	if not on_boat:
		handle_player_movement(delta)
	else:
		handle_boat_logic()

	move_and_slide()

func handle_player_movement(delta):
	# Handle gravity if needed (since gravity is 0, this is skipped)
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("JUMP") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction (left/right)
	var direction = Input.get_axis("move_left", "move_right")

	# Set horizontal velocity based on direction
	velocity.x = direction * SPEED

	# Flip the sprite based on movement direction
	animated_sprite.flip_h = direction < 0

	# Smooth stopping when no direction is pressed
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)

	# Update animations
	update_animation(direction)

	# Check if the player is in the boarding zone to board the boat
	check_for_boarding_zone()

# Function to handle boat-specific logic
func handle_boat_logic():
	velocity = Vector2.ZERO  # Stop player movement on boat
	animated_sprite.play("idle")  # Set idle animation while on boat
	check_for_offboarding_zone()  # Check if player needs to get off the boat

# Function to update animations based on state
func update_animation(direction):
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

# Function to check if the player is in the boarding zone
func check_for_boarding_zone():
	if position.distance_to(boarding_zone.position) < 50:  # Adjust distance threshold
		if not on_boat:  # Only board if not already on the boat
			on_boat = true  # Switch to boat control
			animated_sprite.play("idle")  # Set idle animation when boarding
			print("Player boarded the boat")

# Function to check if the player is in the offboarding zone
func check_for_offboarding_zone():
	if position.distance_to(parking_zone.position) < 50:  # Adjust distance threshold
		if on_boat:  # Only offboard if currently on the boat
			on_boat = false  # Transfer control back to the player
			animated_sprite.play("idle")  # Set to idle animation on disembark
			print("Player left the boat")
