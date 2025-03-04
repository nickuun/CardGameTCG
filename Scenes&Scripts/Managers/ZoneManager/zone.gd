extends Area2D

@export var zone_name: String = "DefaultZone"
@export var is_creature_zone: bool = true 

var cards_in_zone: Array = []
const CARD_SPACING = 130

func add_card_to_zone(card):
	if card in cards_in_zone:
		return

	if self.zone_name == "Player Monster Zone":
		for c in cards_in_zone:
			if c != card:
				c.trigger_ability("on_ally_entered")

	var insert_index = _get_insert_index(card.global_position)
	cards_in_zone.insert(insert_index, card)
	card.set_meta("current_zone", zone_name)
	_reposition_cards()
	
# 📌 Remove a card from the zone (e.g., if moved elsewhere)
func remove_card_from_zone(card):
	if card in cards_in_zone:
		cards_in_zone.erase(card)
		_reposition_cards()

# 📌 Get where in the array the new card should be inserted
func _get_insert_index(card_position) -> int:
	if cards_in_zone.is_empty():
		return 0  # If no cards, insert at the start

	for i in range(cards_in_zone.size()):
		if card_position.x < cards_in_zone[i].global_position.x:
			return i  # Insert before this card

	# If no match, place at the end
	return cards_in_zone.size()

# 📌 Re-arrange all cards in the zone to space them out
func _reposition_cards():
	var start_x = global_position.x - (cards_in_zone.size() - 1) * (CARD_SPACING / 2)
	var y_pos = global_position.y  # Keep them in a straight horizontal line

	for i in range(cards_in_zone.size()):
		var target_position = Vector2(start_x + i * CARD_SPACING, y_pos)
		_animate_card_to_position(cards_in_zone[i], target_position)

# 📌 Smoothly animate a card to its position
func _animate_card_to_position(card, target_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", target_position, 0.4)
	card.update_resting_position(target_position)
