# HandManager.gd
extends Node2D

var my_hand = []
var opponent_hand = []

const CARD_WIDTH = 110
const HAND_Y_POSITION = 996

func add_card_to_hand(card: Node, is_opponent: bool = false):
	if is_opponent:
		opponent_hand.append(card)
		update_opponent_hand_positions()
	else:
		my_hand.append(card)
		update_hand_positions()
		
func remove_card_from_hand(card: Node, is_opponent: bool = false):
	if is_opponent:
		if card in opponent_hand:
			opponent_hand.erase(card)
			update_opponent_hand_positions()
	else:
		if card in my_hand:
			my_hand.erase(card)
			update_hand_positions()

func update_hand_positions():
	for i in range(my_hand.size()):
		var new_position = calculate_card_position(i, my_hand.size())
		var card = my_hand[i]
		card.update_resting_position(new_position)
		animate_card_to_position(card, new_position)

func update_opponent_hand_positions():
	for i in range(opponent_hand.size()):
		var new_position = calculate_opponent_card_position(i, opponent_hand.size())
		var card = opponent_hand[i]
		card.update_resting_position(new_position)
		animate_card_to_position(card, new_position)

func calculate_card_position(index: int, total_cards: int) -> Vector2:
	var total_width = (total_cards - 1) * CARD_WIDTH
	var x_offset = (1920 / 2) + index * CARD_WIDTH - total_width / 2
	# Apply a sine curve for a curved hand effect.
	var curve_intensity = 40.0
	var curve = sin((float(index) / total_cards) * PI) * curve_intensity
	return Vector2(x_offset, HAND_Y_POSITION + curve)

func calculate_opponent_card_position(index: int, total_cards: int) -> Vector2:
	var total_width = (total_cards - 1) * CARD_WIDTH
	var x_offset = (1920 / 2) + index * CARD_WIDTH - total_width / 2
	var y_position = 100  # Fixed Y position at the top.
	return Vector2(x_offset, y_position)

func animate_card_to_position(card: Node2D, new_position: Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.4)
	card.update_resting_position(new_position)

func swap_cards(card1_id: int, card2_id: int, is_opponent: bool = false):
	var hand = opponent_hand if is_opponent else my_hand
	
	var index1 = -1
	var index2 = -1
	
	for i in range(hand.size()):
		if hand[i].get_meta("unique_id") == card1_id:
			index1 = i
		elif hand[i].get_meta("unique_id") == card2_id:
			index2 = i
	
	if index1 != -1 and index2 != -1:
		# ✅ Correct swapping method
		var temp = hand[index1]
		hand[index1] = hand[index2]
		hand[index2] = temp

		if is_opponent:
			update_opponent_hand_positions()
		else:
			update_hand_positions()
	else:
		print("❌ Error: Cards not found for swapping.")


func get_card_by_id(card_id: int, is_opponent: bool = false) -> Node:
	var hand = opponent_hand if is_opponent else my_hand
	for card in hand:
		if card.get_meta("unique_id") == card_id:
			return card
	return null
