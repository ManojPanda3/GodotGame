extends Node2D
@onready var player: CharacterBody2D = $"../Player"

# Parameters for ocean grid
var ocean_grid_size_x = 30
var ocean_grid_size_y = 30
var sst_min = 20.0  # Minimum Sea Surface Temperature
var sst_max = 30.0  # Maximum Sea Surface Temperature
var chlorophyll_min = 0.1  # Minimum Chlorophyll level
var chlorophyll_max = 2.0  # Maximum Chlorophyll level
const c_GridInitializeCord :Vector2i = Vector2i(-450,-450); # :) c_ mean Const and private ok 
# Time variables for updating PFZ
var update_timer = 0
var update_interval = 10  # Interval in seconds for PFZ updates

# Data structure for holding the ocean grid and conditions
var ocean_grid = []

# PFZ Zone Information
var pfz_location = Vector2()
var pfz_radius = 1.5

func _ready():
	randomize()  # Initialize the random number generator
	create_ocean_grid(ocean_grid_size_x, ocean_grid_size_y)
	assign_ocean_conditions()
	pfz_location = identify_PFZ(Vector2(5, 5), pfz_radius)
	update_timer = update_interval
	queue_redraw()  # Force the grid to draw initially
	
func _process(delta):
	# Periodically update the ocean conditions and PFZ
	update_timer -= delta
	if update_timer <= 0:
		assign_ocean_conditions()  # Update SST and Chlorophyll
		pfz_location = identify_PFZ(pfz_location, pfz_radius)  # Update the PFZ location
		shift_PFZ_location()  # Shift the PFZ due to ocean currents
		update_timer = update_interval  # Reset the timer
		queue_redraw()  # Redraw the grid

# Function to create a grid representing the ocean
func create_ocean_grid(width, height):
	ocean_grid.clear()  # Clear the old grid before creating a new one
	for x in range(width):
		var row = []
		for y in range(height):
			var cell = {
				"sst": 0.0,
				"chlorophyll": 0.0
			}
			row.append(cell)
		ocean_grid.append(row)

# Function to assign random sea conditions (SST and Chlorophyll levels)
func assign_ocean_conditions():
	for x in range(ocean_grid_size_x):
		for y in range(ocean_grid_size_y):
			ocean_grid[x][y]["sst"] = randf_range(sst_min, sst_max)  # Use randf_range for floating-point
			ocean_grid[x][y]["chlorophyll"] = randf_range(chlorophyll_min, chlorophyll_max)  # Use randf_range

# Function to identify the Potential Fishing Zone (PFZ) based on SST and Chlorophyll
func identify_PFZ(start_position: Vector2, radius: float) -> Vector2:
	var best_pfz_location = start_position
	var highest_chlorophyll = 0.0

	for x in range(ocean_grid_size_x):
		for y in range(ocean_grid_size_y):
			var sst = ocean_grid[x][y]["sst"]
			var chlorophyll = ocean_grid[x][y]["chlorophyll"]

			if sst >= 25.0 and chlorophyll > highest_chlorophyll:  # Condition for PFZ
				highest_chlorophyll = chlorophyll
				best_pfz_location = Vector2(x, y)

	return best_pfz_location  # Return the best PFZ location

# Function to simulate PFZ movement due to ocean currents
func shift_PFZ_location():
	var wind_direction = randi_range(0, 360)  # Random wind direction
	var wind_strength = randi_range(0.1, 1.0)  # Random wind strength for PFZ shift

	# Calculate the new position of the PFZ based on wind
	pfz_location.x += wind_strength * cos(deg_to_rad(wind_direction))
	pfz_location.y += wind_strength * sin(deg_to_rad(wind_direction))

	# Clamp the PFZ location to stay within the ocean grid boundaries
	pfz_location.x = clamp(pfz_location.x, 0, ocean_grid_size_x - 1)
	pfz_location.y = clamp(pfz_location.y, 0, ocean_grid_size_y - 1)

# Function to handle the ocean grid when resizing
func resize_ocean_grid(new_width, new_height):
	ocean_grid_size_x = new_width
	ocean_grid_size_y = new_height
	create_ocean_grid(ocean_grid_size_x, ocean_grid_size_y)
	assign_ocean_conditions()
	pfz_location = identify_PFZ(pfz_location, pfz_radius)  # Recalculate PFZ location within new grid

# Function to draw the ocean grid and PFZ on the screen
var _Padding:Vector2 = c_GridInitializeCord/Vector2i(ocean_grid_size_x,ocean_grid_size_y)

func _draw():
	var cell_size = 40  # Size of each grid cell
	for x in range(ocean_grid_size_x):
		for y in range(ocean_grid_size_y):
			var sst = ocean_grid[x][y]["sst"]
			var color_value = (sst - sst_min) / (sst_max - sst_min)
			var color = Color(1, color_value, 0)  # Red gradient for SST

			draw_rect(Rect2((Vector2(x, y)+_Padding) * cell_size, Vector2(cell_size, cell_size)), color)

	# Draw the PFZ zone
	draw_circle(pfz_location * cell_size + Vector2(cell_size / 2, cell_size / 2), pfz_radius * cell_size, Color(0, 1, 0, 0.5))
