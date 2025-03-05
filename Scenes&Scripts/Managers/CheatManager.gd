extends Control

@onready var input_field: TextEdit = $TextEdit

@export var turn_manager: NodePath
@export var card_manager: NodePath

var command_history: Array = []
var history_index: int = -1
var command_map: Dictionary = {
	"draw_card": func(): get_node(card_manager).draw_card(),
	
	"draw_opponent_card": func():
	get_node(card_manager).draw_card(true),
	
	"swap_cards": func():
	var card_manager_node = get_node(card_manager)
	var hand_manager = card_manager_node.get_node(card_manager_node.hand_manager_path)

	if hand_manager.my_hand.size() >= 2:
		var card1_id = hand_manager.my_hand[0].get_meta("unique_id")
		var card2_id = hand_manager.my_hand[1].get_meta("unique_id")

		card_manager_node.swap_cards(card1_id, card2_id)
		print("Swapped cards:", card1_id, "and", card2_id)
	else:
		print("Not enough cards to swap"),
		
	"sync_opponent_swap": func():
		var card_manager_node = get_node(card_manager)
		var hand_manager = card_manager_node.get_node(card_manager_node.hand_manager_path)
		if hand_manager.opponent_hand.size() >= 2:
			var card1_id = hand_manager.opponent_hand[0].get_meta("unique_id")
			var card2_id = hand_manager.opponent_hand[1].get_meta("unique_id")
			card_manager_node.sync_opponent_card_swap(card1_id, card2_id)
		else:
			print("❌ Not enough opponent cards to swap"),

	"sync_opponent_placement": func():
		var card_manager_node = get_node(card_manager)
		var hand_manager = card_manager_node.get_node(card_manager_node.hand_manager_path)
		if hand_manager.opponent_hand.size() > 0:
			var card_id = hand_manager.opponent_hand[0].get_meta("unique_id")
			card_manager_node.sync_opponent_card_placement(card_id, "Opponent Monster Zone")
		else:
			print("❌ No opponent card available for placement"),
	
	"test_attack": func():
		var card_manager_node = get_node(card_manager)
		var battle_manager = get_node(card_manager_node.battle_manager_path)
		var zone_manager = get_node(card_manager_node.zone_manager_path)

		# Get played creatures from the Monster Zones
		var player_monster_zone = zone_manager.get_zone_by_name("Player Monster Zone")
		var opponent_monster_zone = zone_manager.get_zone_by_name("Opponent Monster Zone")

		if player_monster_zone.cards_in_zone.size() > 0 and opponent_monster_zone.cards_in_zone.size() > 0:
			var attacker = player_monster_zone.cards_in_zone[0]  # First creature in Player Monster Zone
			var defender = opponent_monster_zone.cards_in_zone[0]  # First creature in Opponent Monster Zone

			print("⚔️ TESTING COMBAT:", attacker.name, "vs", defender.name)
			battle_manager.apply_combat(attacker, defender)
		else:
			print("❌ Not enough creatures in zones for battle!"),
	
	"hover_card": func(): print("CHEATING"),
	"end_turn": func():get_node(turn_manager).end_turn(),
	"give_mana": func(): print("CHEATING")
}

func _ready():
	# Hide console by default
	visible = false
	input_field.visible = false
	# Capture keyboard focus when shown
	input_field.grab_focus()

func _input(event):
	if event is InputEventKey:
		if !event.pressed:
			match event.keycode:
				KEY_SLASH:  # Open console
					_toggle_console()
				KEY_ESCAPE:  # Close console
					_hide_console()
				KEY_UP:  # Navigate command history up
					_navigate_history(-1)
				KEY_DOWN:  # Navigate command history down
					_navigate_history(1)
				KEY_ENTER:  # Execute command
					_execute_command()

func _toggle_console():
	visible = !visible
	input_field.visible = visible
	if visible:
		input_field.grab_focus()
		input_field.text = ""
		history_index = len(command_history)  # Reset history index

func _hide_console():
	visible = false
	input_field.visible = false
	input_field.release_focus()
	
func _navigate_history(direction: int):
	if command_history.is_empty():
		return

	history_index = clamp(history_index + direction, 0, len(command_history) - 1)
	input_field.text = command_history[history_index]
	input_field.set_caret_column(len(input_field.text))  # Move cursor to end
	
func _execute_command():
	var command = input_field.text.strip_edges()
	if command.is_empty():
		_hide_console()
		return
	
	# Add command to history
	if command_history.is_empty() or command_history[-1] != command:
		command_history.append(command)
	history_index = len(command_history)

	# Execute the command if it exists
	if command_map.has(command):
		command_map[command].call()
		print("Executed command:", command)
	else:
		print("Unknown command:", command)

	# Hide console after execution
	_hide_console()
