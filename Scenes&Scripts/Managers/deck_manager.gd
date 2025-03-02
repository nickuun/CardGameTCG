# DeckManager.gd
extends Node

var deck = []
var current_index = 0

var opponent_deck = [] 
var opponent_current_index = 0 

func _ready():

	#deck = [
		#{"id": 1, "title": "Warrior", "type": "Creature", "description": "Strong fighter", 
		 #"attack": "3", "defense": "2", "cost": "3",
		 #"abilities": [{"trigger": "on_played", "function": "deal_damage_to_hero"}]},
#
		#{"id": 2, "title": "Cleric", "type": "Creature", "description": "Healer", 
		 #"attack": "1", "defense": "4", "cost": "4",
		 #"abilities": [{"trigger": "on_played", "function": "heal_all_allies"}]},
#
		#{"id": 3, "title": "Undead", "type": "Creature", "description": "Revenant", 
		 #"attack": "2", "defense": "1", "cost": "2",
		 #"abilities": [
			#{"trigger": "on_played", "function": "heal_all_allies"},
			#{"trigger": "on_death", "function": "deal_damage_to_hero"}
		 #]}
	#]
	var desired_player_cards = [
		"vinegrasp_aura_009",  # ID from CSV row
		"mosshide_bear_006",
		"briarclaw_shaman_005",
		"impish_trickster_011",
		"lupine_curse_012",
	]
	
	for card_id in desired_player_cards:
		var card_info = CardDatabase.get_card(card_id)
		# Make sure the card exists in CSV
		if card_info.size() > 0:
			deck.append(card_info)
		else:
			print("⚠️ Could not find card:", card_id)

	deck.shuffle()
	sample_opponent_deck()

func sample_opponent_deck():

	var desired_opponent_cards = [
		"impish_trickster_011",
		"impish_trickster_011",  
		"impish_trickster_011" 
	]

	var sample_opponent_deck = []
	for card_id in desired_opponent_cards:
		var card_info = CardDatabase.get_card(card_id)
		if card_info.size() > 0:
			sample_opponent_deck.append(card_info)

	set_opponent_deck(sample_opponent_deck)

func set_opponent_deck(opponent_deck_data: Array):
	opponent_deck = opponent_deck_data.duplicate()
	opponent_current_index = 0

func draw_card_data(is_opponent: bool = false) -> Dictionary:
	if is_opponent:
		if opponent_current_index < opponent_deck.size():
			var card_data = opponent_deck[opponent_current_index]
			opponent_current_index += 1
			return card_data
		else:
			print("⚠️ No more opponent cards to draw.")
			return {}
	else:
		if current_index < deck.size():
			var card_data = deck[current_index]
			current_index += 1
			return card_data
		else:
			print("⚠️ No more player cards to draw.")
			return {}
