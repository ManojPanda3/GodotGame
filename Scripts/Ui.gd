extends Control

var advisory_text

func _ready():
	advisory_text = $AdvisoryLabel  # Reference to a label on the UI to display PFZ advisory

func update_advisory(advisory_list):
	advisory_text.text = "\n".join(advisory_list)
