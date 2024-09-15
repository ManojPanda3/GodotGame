extends Node2D

const Fish = ["Minnow","Perch","Salmon","Pike","Tuna"];
@onready var pop_up: Label = $Boat/PopUp.get_node("Text")
@onready var counter: Label = $Boat/Counter.get_node("Text")
@onready var map: TileMap = $map
@onready var player: CharacterBody2D = $Boat

var fishCatched = 0;

func fishing() -> String:
	var probability = randf_range(0,1);
	var fish = Fish[randi_range(0,len(Fish)*probability)];
	pop_up.text = "You Catched: " + str(fish);
	fishCatched+=1;
	counter.text = "Number of fish catched: " + str(fishCatched);
	return fish;


func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("fishing")):
		fishing();
