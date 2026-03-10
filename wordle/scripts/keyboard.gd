extends VBoxContainer


class_name Keyboard

signal letter_pressed(letter: String)
signal backspace_spressed
signal enter_pressed


func _on_keyboard_button_pressed(letter: String):
	letter_pressed.emit(letter)


func _on_backspace_button_pressed() -> void:
	backspace_spressed.emit()


func _on_enter_pressed() -> void:
	enter_pressed.emit()

func on_letters_validated(usedLetters, validationResult):
	var best_state_per_letter := {}
	for i in usedLetters.size():
			var ch = String(usedLetters[i]).to_lower()
			var st = int(validationResult[i])
			if !best_state_per_letter.has(ch) or st > best_state_per_letter[ch]:
				best_state_per_letter[ch] = st
				
	var keys = get_tree().get_nodes_in_group("keyboard") as Array[KeyboardButton]
	
	for key in keys:
		var ch = key.name.to_lower()
		if best_state_per_letter.has(ch):
			key.set_state(best_state_per_letter[ch])
