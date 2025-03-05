extends Node

# Track whose turn it is (true = player's turn, false = opponent's)
var is_player_turn: bool = true

@export var card_manager_path: NodePath
@export var deck_manager_path: NodePath
@export var player_manager_path: NodePath
@export var zone_manager_path: NodePath

var card_manager
var deck_manager
var player_manager
var zone_manager

func _ready():
	card_manager = get_node(card_manager_path)
	deck_manager = get_node(deck_manager_path)
	player_manager = get_node(player_manager_path)
	zone_manager = get_node(zone_manager_path)
	
# Called by the End Turn Button's "pressed" signal.
func on_end_turn_pressed():
	if is_player_turn:
		end_turn()
		$Button.disabled = true
	else:
		print("Can't end opponent's turn!")

func end_turn():
	print("Ending turn for ", is_player_turn,  " Player" )
	is_player_turn = !is_player_turn

	start_turn()

func start_turn():
	
	if is_player_turn:
		$AnimationPlayer.play("ShowTurnBanner")
		$Button.disabled = false
		for card in zone_manager.get_zone_by_name("Player Monster Zone").cards_in_zone:
			card.trigger_ability("on_turn_start")
		print("Starting player's turn")
		var card = card_manager.draw_card()
		_refresh_exhausted(false) 
		# Increase max mana (capped at 10) and refill:
		player_manager.player_max_mana = min(10, player_manager.player_max_mana + 1)
		player_manager.player_mana = player_manager.player_max_mana
		player_manager.update_mana_display(false)
		print("Player mana refilled to", player_manager.player_mana)
		
	else:
		print("Starting opponent's turn")
		card_manager.draw_card(true)
		_refresh_exhausted(true)
		player_manager.opponent_max_mana = min(10, player_manager.opponent_max_mana + 1)
		player_manager.opponent_mana = player_manager.opponent_max_mana
		player_manager.update_mana_display(true)
		print("Opponent mana refilled to", player_manager.opponent_mana)

func _refresh_exhausted(is_opponent: bool):
	zone_manager.refresh_exhausted(is_opponent)
