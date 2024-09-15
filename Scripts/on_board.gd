# OnBoardZone.gd
extends Area2D

# Signal for when the player enters the onboard zone
signal player_entered_onboard

# Detect when a body enters the onboard zone
func _on_OnBoardZone_body_entered(body):
	if body.name == "Player":  # Assuming the player is named "Player"
		emit_signal("player_entered_onboard", body)
