extends ColorRect


class_name ResultsUI

@export var win_color: Color
@export var lose_color: Color
@export var alpha_factor: float = 0.4

@onready var results_label: Label = $CenterContainer/Panel/VBoxContainer/ResultsLabel
@onready var word_label: Label = $CenterContainer/Panel/VBoxContainer/WordLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	

func show_results(has_won: bool, word: String, number_of_moves: int):
	var clear_color = win_color if has_won else lose_color
	var color_with_alpha = Color(clear_color, alpha_factor)
	word_label.text = word
	word_label.add_theme_color_override("font_color", clear_color)
	
	var moves_string = "Zug" if number_of_moves == 1 else "Zügen"
	
	results_label.text = "Du hast in " + str(number_of_moves) + " " + moves_string + " gewonnen!" if has_won else "Du hast verloren!"
	color = color_with_alpha
	show()

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
