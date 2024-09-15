# ParkingZone.gd
extends Area2D

# Signal for when the boat enters the parking zone
signal boat_entered_parking

# Detect when a body enters the parking zone
func _on_ParkingZone_body_entered(body):
	if body.name == "Boat":  # Assuming the boat is named "Boat"
		emit_signal("boat_entered_parking", body)
