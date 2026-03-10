extends Node

class_name RowsController


@onready var wordPool = $WordPool
@onready var keyboard = %Keyboard
@onready var valildationAlert = %ValidationAlert
@onready var results_ui: ResultsUI = %ResultsUI



@onready var rows: Array[HBoxContainer] = [
	$MarginContainer/VBoxContainer/CenterContainer/Rows/Row,
	$MarginContainer/VBoxContainer/CenterContainer/Rows/Row2,
	$MarginContainer/VBoxContainer/CenterContainer/Rows/Row3,
	$MarginContainer/VBoxContainer/CenterContainer/Rows/Row4,
	$MarginContainer/VBoxContainer/CenterContainer/Rows/Row5
]

var activeRowIndex = 0
var activeLetterIndex = -1
var isRowFilled = false
var letters
var letter_tiles

var wordToGuess = ""

func _ready() -> void:
	wordToGuess = wordPool.get_random_word()


func _on_keyboard_backspace_spressed() -> void:
	if activeLetterIndex >= 0:
		rows[activeRowIndex].get_child(activeLetterIndex).letter = ''
		activeLetterIndex -= 1


func _on_keyboard_enter_pressed() -> void:
	var is_length_valid = validate_length();
	if !is_length_valid:
		return
	
	letter_tiles = rows[activeRowIndex].get_children()
	letters = letter_tiles.map(func (c): return c.letter)
	var wordToCheck =  "".join(letters)
	
	if wordPool.check_word(wordToCheck.to_upper()):
		on_word_valid(wordToCheck, letters)
	else:
		valildationAlert.show_with_text("Wort existiert nicht")
	

func on_word_valid(word_typed: String, letters):
	var validationResult = validate_word(wordToGuess, letters)
	
	for i in letter_tiles.size():
		letter_tiles[i].set_tile_state(validationResult[i])
		
	keyboard.on_letters_validated(letters, validationResult)
	
	if validationResult.all(func (r): return r == Enums.State.CorrectRightPlacement):
		on_win()
	else: 
		activeRowIndex += 1
		activeLetterIndex = -1
	
	if activeRowIndex == rows.size():
		on_lose()


func validate_word(target_word: String, guess_letters: Array) -> Array[Enums.State]:
	var target_upper = target_word.to_upper()
	var guess_upper = guess_letters.map(func(l): return l.to_upper())
	var result: Array[Enums.State] = []
	var letter_counts := {}

	# Einmalig mit Empty füllen
	for i in guess_upper.size():
		result.append(Enums.State.Empty)

	# 1) Häufigkeiten im Zielwort
	for c in target_upper:
		if letter_counts.has(c):
			letter_counts[c] += 1
		else:
			letter_counts[c] = 1

	# 2) Richtige Position
	for i in guess_upper.size():
		if guess_upper[i] == target_upper[i]:
			result[i] = Enums.State.CorrectRightPlacement
			letter_counts[guess_upper[i]] -= 1

	# 3) Falsche Position
	for i in guess_upper.size():
		if result[i] != Enums.State.Empty:
			continue

		var letter = guess_upper[i]
		if letter_counts.has(letter) and letter_counts[letter] > 0:
			result[i] = Enums.State.CorrectWrongPlacement
			letter_counts[letter] -= 1
		else:
			result[i] = Enums.State.Incorrect

	return result




func _on_keyboard_letter_pressed(letter: String) -> void:
	if activeLetterIndex < 4:
		activeLetterIndex += 1
	
	if activeLetterIndex <= 4:
		rows[activeRowIndex].get_child(activeLetterIndex).letter = letter

func validate_length():
	if activeLetterIndex == 4:
		return true
	
	valildationAlert.show_with_text("Zu wenig Buchstaben")
	return false

func on_win():
	#set_process_input(false) für deaktivierung der tastatureingaben
	disconnect_keyboard_signals()
	results_ui.show_results(true, wordToGuess, activeRowIndex + 1)

func on_lose():
	#set_process_input(false)
	disconnect_keyboard_signals()
	results_ui.show_results(false, wordToGuess, -1)

func disconnect_keyboard_signals():
	keyboard.backspace_spressed.disconnect(_on_keyboard_backspace_spressed)
	keyboard.enter_pressed.disconnect(_on_keyboard_enter_pressed)
	keyboard.letter_pressed.disconnect(_on_keyboard_letter_pressed)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and !event.echo and results_ui.visible == false:
		var key_event := event as InputEventKey
		
		if key_event.keycode == Key.KEY_ENTER or key_event.keycode == Key.KEY_KP_ENTER:
			_on_keyboard_enter_pressed()
			get_viewport().set_input_as_handled()
			return
			
		if key_event.keycode == Key.KEY_BACKSPACE:
			_on_keyboard_backspace_spressed()
			get_viewport().set_input_as_handled()
			return
			
		if key_event.unicode > 0:
			var ch := char(key_event.unicode)
			ch = ch.to_upper()
			if ch.length() == 1 and ch >= "A" and ch <= "Z":
				_on_keyboard_letter_pressed(ch)
				get_viewport().set_input_as_handled()
				return
		
			_on_keyboard_letter_pressed(ch)
			get_viewport().set_input_as_handled()
			return
			
		var kc := key_event.keycode
		if kc >= Key.KEY_A and kc <= Key.KEY_Z:
			var ch2 := char(kc)
			_on_keyboard_letter_pressed(String(ch2))
			get_viewport().set_input_as_handled()
			return
