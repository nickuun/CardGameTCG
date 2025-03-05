# CardManager.gd
extends Node2D

@export var deck_manager_path: NodePath
@export var hand_manager_path: NodePath
@export var card_id_manager_path: NodePath
@export var zone_manager_path: NodePath
@export var battle_manager_path: NodePath
@export var player_manager_path: NodePath

@export var card_scene: PackedScene = preload("res://Scenes&Scripts/Cards/Card/card.tscn")


var deck_manager = null
var hand_manager = null
var card_id_manager = null
var zone_manager = null
var battle_manager = null
var player_manager = null

func _ready():
	deck_manager = get_node(deck_manager_path)
	hand_manager = get_node(hand_manager_path)
	card_id_manager = get_node(card_id_manager_path)  
	zone_manager = get_node(zone_manager_path)
	battle_manager = get_node(battle_manager_path)
	player_manager = get_node(player_manager_path)
	
# Draws a card from the deck and adds it to the appropriate hand.
func draw_card(is_opponent: bool = false) -> Node:
	var card_data = deck_manager.draw_card_data(is_opponent)
	if card_data and card_data.size() > 0:
		var new_card = card_scene.instantiate()
		new_card.name = "Card"
# Assign card properties (assumes your card scene has a set_card() method)
		new_card.set_card(
			card_data["id"],
			card_data["title"],
			card_data["type"],
			card_data["description"],
			card_data["attack"],
			card_data["defense"],
			card_data["cost"],
			card_data["abilities"]
		)
# Assign a unique network-synchronized ID using the CardIDManager.
		var unique_id = card_id_manager.get_new_card_id()
		new_card.set_meta("unique_id", unique_id)
		
		if is_opponent:
			new_card.set_meta("owner", "opponent")
		else:
			new_card.set_meta("owner", "player")
			new_card.flip_card()
		
		# Add the card to the scene and to the appropriate hand.
		add_child(new_card)
		hand_manager.add_card_to_hand(new_card, is_opponent)
		return new_card
	else:
		print("No more cards to draw!")
	return null

func swap_cards(card1_id: int, card2_id: int):
	hand_manager.swap_cards(card1_id, card2_id)

func sync_opponent_card_swap(card1_id: int, card2_id: int):
	hand_manager.swap_cards(card1_id, card2_id, true)
	print("🔄 Synced opponent card swap:", card1_id, "<->", card2_id)

func sync_opponent_card_placement(card_id: int, zone_name: String):
	
	var card = hand_manager.get_card_by_id(card_id, true)
	player_manager.subtract_mana(int(card.get_meta("card_mana_cost")), true)
	var zone = zone_manager.get_zone_by_name(zone_name)
	if card and zone:
		card.flip_card()
		hand_manager.remove_card_from_hand(card, true)
		zone.add_card_to_zone(card)
		print("🃏 Synced opponent card placement:", card.name, "->", zone_name)
	else:
		print("❌ Failed to sync placement. Card or zone not found.")
