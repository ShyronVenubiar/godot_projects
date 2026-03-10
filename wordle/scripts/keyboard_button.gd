extends Button


class_name KeyboardButton

@export var letter: String

@export var state: Enums.State = Enums.State.Empty

const state_to_theme_variation = ["letter_available", "used", "correct_wrong_placement", "correct_right_placement"]

func _ready() -> void:
	name = letter
	theme_type_variation = state_to_theme_variation[state]
	text = letter
	
func set_state(new_state: Enums.State):
#	Deactive used letters (when activate, needs also deactivation of keyboard variants)
	#if new_state == Enums.State.Incorrect:
		#disabled = true
	if state != Enums.State.CorrectRightPlacement:
		state = new_state
		theme_type_variation = state_to_theme_variation[state]
