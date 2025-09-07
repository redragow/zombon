# res://autoload/GameManager.gd
extends Node

enum Difficulty { EASY, MEDIUM, HARD }
enum GameState { MENU, PLAYING, PAUSED }

var current_difficulty = Difficulty.MEDIUM
var current_save_slot = -1
var game_state = GameState.MENU
var player_data = {}
var player_ref = null

func _ready():
	print("GameManager initialized")
	initialize_default_input_map()

# --- Методы управления состоянием ---
func set_difficulty(difficulty):
	current_difficulty = difficulty
	print("Difficulty set to: ", difficulty)

func get_difficulty():
	return current_difficulty

func set_game_state(state):
	game_state = state
	print("Game state set to: ", state)

func get_game_state():
	return game_state

# --- Управление ссылкой на игрока ---
func set_player_reference(player):
	player_ref = player
	print("Player reference set in GameManager")

func get_player_reference():
	return player_ref

# --- Методы для сохранения/загрузки ---
func save_game(slot: int, position: Vector2, health: int, score: int) -> bool:
	var save_data = {
		"player_data": {
			"position": position,
			"health": health,
			"score": score,
			"difficulty": current_difficulty
		},
		"timestamp": Time.get_unix_time_from_system()
	}

	var file = FileAccess.open("user://save_" + str(slot) + ".save", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Game saved successfully to slot ", slot)
		return true
	else:
		print("ERROR: Could not open file for saving: user://save_", slot, ".save")
		return false

func load_game(slot: int) -> bool:
	var save_path = "user://save_" + str(slot) + ".save"
	if not FileAccess.file_exists(save_path):
		print("ERROR: Save file does not exist: ", save_path)
		return false
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		if save_data.has("player_data"):
			player_data = save_data["player_data"]
		if player_ref:
			if player_data.has("position"):
				player_ref.position = Vector2(player_data["position"].x, player_data["position"].y)
			if player_data.has("health"):
				player_ref.health = player_data["health"] # Присваиваем значение переменной
			if player_data.has("score"):
				player_ref.score = player_data["score"]   # Присваиваем значение переменной
			current_difficulty = player_data.get("difficulty", current_difficulty)
			current_save_slot = slot
			print("Game loaded successfully from slot ", slot)
			return true
		else:
			print("ERROR: Player reference is not set!")
	else:
		print("ERROR: Could not open file for loading: ", save_path)
	return false

# Новый метод: Загружает данные игры в player_data, но НЕ применяет их к игроку.
# Используется при загрузке из главного меню.
func load_game_data_only(slot: int) -> bool:
	var save_path = "user://save_" + str(slot) + ".save"
	if not FileAccess.file_exists(save_path):
		print("ERROR: Save file does not exist: ", save_path)
		return false
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		if save_data.has("player_data"):
			player_data = save_data["player_data"]
			current_difficulty = player_data.get("difficulty", current_difficulty)
			current_save_slot = slot
			print("Game data loaded successfully from slot ", slot, " into player_data.")
			return true
		else:
			print("ERROR: Save data is missing player_data")
	else:
		print("ERROR: Could not open file for loading: ", save_path)
	return false

func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists("user://save_" + str(slot) + ".save")

func get_slot_timestamp(slot: int) -> int:
	if not slot_exists(slot):
		return 0
	var file = FileAccess.open("user://save_" + str(slot) + ".save", FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()
		return data.get("timestamp", 0)
	return 0

# --- Инициализация InputMap ---
func initialize_default_input_map():
	print("Initializing default input map...")

	# Список действий и их стандартных событий (клавиатура + геймпад)
	var actions_config = {
		"move_left": [
			{ "type": "key", "code": KEY_A },
			{ "type": "joy_button", "index": 14 }, # D-Pad Left
			{ "type": "joy_axis", "axis": 0, "value": -1.0 } # Left Stick Left
		],
		"move_right": [
			{ "type": "key", "code": KEY_D },
			{ "type": "joy_button", "index": 15 }, # D-Pad Right
			{ "type": "joy_axis", "axis": 0, "value": 1.0 } # Left Stick Right
		],
		"jump": [
			{ "type": "key", "code": KEY_SPACE },
			{ "type": "joy_button", "index": 0 }, # X (Cross)
			{ "type": "joy_button", "index": 7 }  # R2 Trigger
		],
		"attack": [
			{ "type": "key", "code": KEY_Z },
			{ "type": "joy_button", "index": 2 }, # Square
			{ "type": "joy_button", "index": 1 }  # Circle
		],
		"ui_accept": [
			{ "type": "key", "code": KEY_ENTER },
			{ "type": "key", "code": KEY_SPACE },
			{ "type": "joy_button", "index": 0 } # X (Cross)
		],
		"ui_cancel": [
			{ "type": "key", "code": KEY_ESCAPE },
			{ "type": "joy_button", "index": 1 }, # Circle
			{ "type": "joy_button", "index": 9 }  # Start/Pause
		],
		"ui_up": [
			{ "type": "key", "code": KEY_UP },
			{ "type": "joy_button", "index": 12 }, # D-Pad Up
			{ "type": "joy_axis", "axis": 1, "value": -1.0 } # Left Stick Up
		],
		"ui_down": [
			{ "type": "key", "code": KEY_DOWN },
			{ "type": "joy_button", "index": 13 }, # D-Pad Down
			{ "type": "joy_axis", "axis": 1, "value": 1.0 } # Left Stick Down
		],
		"ui_left": [
			{ "type": "key", "code": KEY_LEFT },
			{ "type": "joy_button", "index": 14 }, # D-Pad Left
			{ "type": "joy_axis", "axis": 0, "value": -1.0 } # Left Stick Left
		],
		"ui_right": [
			{ "type": "key", "code": KEY_RIGHT },
			{ "type": "joy_button", "index": 15 }, # D-Pad Right
			{ "type": "joy_axis", "axis": 0, "value": 1.0 } # Left Stick Right
		]
	}

	for action_name in actions_config.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		# Очищаем все текущие события для этого действия
		InputMap.action_erase_events(action_name)

		# Добавляем все события из конфигурации
		for event_config in actions_config[action_name]:
			var input_event = null
			match event_config.type:
				"key":
					input_event = InputEventKey.new()
					input_event.keycode = event_config.code
				"joy_button":
					input_event = InputEventJoypadButton.new()
					input_event.button_index = event_config.index
				"joy_axis":
					input_event = InputEventJoypadMotion.new()
					input_event.axis = event_config.axis
					input_event.axis_value = event_config.value
			if input_event:
				InputMap.action_add_event(action_name, input_event)

	print("Default input map initialized with keyboard and gamepad support.")

# - Методы для работы с данными игрока -
func save_player_data(position, health, score):
	player_data = {
		"position": {
			"x": position.x,
			"y": position.y
		},
		"health": health,
		"score": score,
		"difficulty": current_difficulty,
		"timestamp": Time.get_unix_time_from_system()
	}

func get_player_data() -> Dictionary:
	return player_data
