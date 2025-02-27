extends Node

# Track whose turn it is (true = player's turn, false = opponent's)
var is_player_turn: bool = true

@export var card_manager_path: NodePath
@export var deck_manager_path: NodePath
@export var player_manager_path: NodePath

var card_manager
var deck_manager
var player_manager

func _ready():
	card_manager = get_node(card_manager_path)
	deck_manager = get_node(deck_manager_path)
	player_manager = get_node(player_manager_path)

# Called by the End Turn Button's "pressed" signal.
func on_end_turn_pressed():
	end_turn()

func end_turn():
	print("Ending turn for ", is_player_turn,  " Player" )
	is_player_turn = !is_player_turn
	start_turn()

func start_turn():
	if is_player_turn:
		print("Starting player's turn")
		var card = card_manager.draw_card()
		# Increase max mana (capped at 10) and refill:
		player_manager.player_max_mana = min(10, player_manager.player_max_mana + 1)
		player_manager.player_mana = player_manager.player_max_mana
		player_manager.update_mana_display(false)
		print("Player mana refilled to", player_manager.player_mana)
		
	else:
		print("Starting opponent's turn")
		card_manager.draw_card(true)
		player_manager.opponent_max_mana = min(10, player_manager.opponent_max_mana + 1)
		player_manager.opponent_mana = player_manager.opponent_max_mana
		player_manager.update_mana_display(true)
		print("Opponent mana refilled to", player_manager.opponent_mana)
