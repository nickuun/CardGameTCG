extends Node2D

var last_hovered_card = null  # Track the last hovered card
var hovered_cards = []  # Store all hovered cards
var CardPreviewNode

func _ready() -> void:
	CardPreviewNode = self.get_tree().get_first_node_in_group("CardPreview")

func _process(delta):
	hovered_cards = raycast_check_for_cards()

	# If hovering the same card, do nothing
	if hovered_cards.size() > 0 and hovered_cards[0] == last_hovered_card:
		return  

	# If we are hovering nothing, reset the last hovered card
	if hovered_cards.is_empty():
		if last_hovered_card:
			last_hovered_card.reset_position()
			last_hovered_card.apply_shader(false) 
			last_hovered_card = null
			CardPreviewNode.hide()
			#MultiplayerActionInterpreter.PingLobby({"CardHovered": null} , 6)
		return  # Stop here, nothing else to process

	var detected_card = hovered_cards[0]  # Prioritize the first detected card

	# If a new card is detected, only switch if the last one is *completely* gone
	if last_hovered_card and is_still_hovering(last_hovered_card):
		return  # Don't switch yet if we're still over the last card

	# Otherwise, reset the old card and raise the new one
	if last_hovered_card:
		last_hovered_card.apply_shader(false) 
		last_hovered_card.reset_position()
	
	if detected_card.has_method("raise_card"):
		detected_card.apply_shader(true, true) 
		#MultiplayerActionInterpreter.PingLobby({"CardHovered": detected_card.get_meta("unique_id")} , 6)
		detected_card.raise_card()
		detected_card.set_preview()
	last_hovered_card = detected_card  # Update the last hovered card

func raycast_check_for_cards():
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = 1  # Ensure your card's collision layer matches this

	var result = space_state.intersect_point(params)
	var cards = []

	for res in result:
		var card = res.collider.get_parent()
		if card and card not in cards:
			cards.append(card)

	return cards

func is_still_hovering(card) -> bool:
	# Check if the currently hovered card is still under the mouse
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = 1  # Same collision layer

	var result = space_state.intersect_point(params)
	for res in result:
		if res.collider.get_parent() == card:
			return true  # The previous card is still hovered

	return false  # The previous card is no longer hovered

func get_hovered_entities():
	print("get_hovered_entities' hovered_cards",hovered_cards)
	return hovered_cards
