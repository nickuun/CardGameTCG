extends Node2D

var dragged_card = null
var drag_offset = Vector2.ZERO
@export var zone_manager: NodePath
@export var hand_manager : NodePath
@export var battle_manager : NodePath
@export var card_preview : NodePath
@export var player_manager : NodePath
@export var turn_manager : NodePath
@export var ability_manager : NodePath
@export var graveyard_manager : NodePath

var zone_manager_node = null  # Store reference to the ZoneManager instance
var hand_manager_node = null
var battle_manager_node = null
var card_preview_node = null
var player_manager_node = null
var turn_manager_node = null
var ability_manager_node = null
var graveyard_manager_node = null

func _ready() -> void:
	set_process_input(true)
	# Get the ZoneManager node from the scene tree.
	if zone_manager:
		zone_manager_node = get_node(zone_manager)
	if hand_manager:
		hand_manager_node = get_node(hand_manager)
	if battle_manager:
		battle_manager_node = get_node(battle_manager)
	if card_preview:
		card_preview_node = get_node(card_preview)
	if player_manager:
		player_manager_node = get_node(player_manager)
	if turn_manager:
		turn_manager_node = get_node(turn_manager)
	if ability_manager:
		ability_manager_node = get_node(ability_manager)
	if graveyard_manager:
		graveyard_manager_node = get_node(graveyard_manager)
		
func _input(event: InputEvent) -> void:
	# Handle mouse button press (Left Click)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			
			 # If we have a pending ability in the ability manager:
			if ability_manager_node.pending_ability != null:
				var hovered_card = _get_card_under_mouse()
				if hovered_card:
					# Check if it's in the player's creature zone
					var zone_name = hovered_card.get_meta("current_zone", "")
					var card_type = hovered_card.get_meta("card_type", "")
					if "Monster Zone" in zone_name and card_type == "Creature":
						 #and "Opponent" not in zone_name? need conditional option - REFACTOR
						# Valid target -> apply
						ability_manager_node.apply_pending_ability_to_target(hovered_card)
						print("🎯 Target selected:", hovered_card.name)
					else:
						print("❌ Invalid target for this ability")
				return  # End target selection path, do not proceed with normal dragging
			
			var card = _get_card_under_mouse()
			if card:
				var card_zone = card.get_meta("current_zone") if card.has_meta("current_zone") else "Unknown"

				# 📌 If clicking a card in Player Monster Zone → Start attack mode
				if "Monster Zone" in card_zone and "Opponent" not in card_zone:
					print("⚔️ New attacker selected:", card.name)
					battle_manager_node.start_attack(card)
					return  # Prevent normal dragging behavior

				# 📌 Prevent dragging opponent's cards
				if "Opponent" in card_zone:
					print("❌ Cannot interact with opponent's card:", card.name)
					return  

				# 📌 Normal dragging (Hand or Zone)
				if card in hand_manager_node.my_hand:
					print("✅ Dragging allowed:", card.name)
					dragged_card = card
					drag_offset = card.global_position - get_viewport().get_mouse_position()
					if card.has_method("on_drag_start"):
						card.on_drag_start()
					return

		else:
			# 📌 Mouse released - Check if we were in attack mode or dragging normally
			if battle_manager_node.attacking_card:
				
				var target_card = _get_card_under_mouse()
				var target_opponent = _get_opponent_under_mouse()  # NEW FUNCTION

				if target_card and target_card != battle_manager_node.attacking_card:
					var target_zone = target_card.get_meta("current_zone") if target_card.has_meta("current_zone") else "Unknown"

					# Attack opponent monster
					if "Opponent Monster Zone" in target_zone:
						print("🔥 Attacking", target_card.name, "with", battle_manager_node.attacking_card.name)
						battle_manager_node.attempt_attack(target_card)
				
				elif target_opponent:
					print("🔥 Direct attack on opponent!")
					battle_manager_node.direct_attack()
				
				# Reset attacker on release
				battle_manager_node.attacking_card = null
				return  

			# 📌 If dragging a card, handle drop behavior (swaps/zones)
			if dragged_card:
				print("🖱️ Mouse released, checking for swap or zone placement...")

				var target_card = _get_card_under_mouse()
				if target_card and target_card != dragged_card:
					_swap_cards_in_hand(dragged_card, target_card)
				else:
					var dropped_zone = _get_zone_under_mouse()
					if dropped_zone:
						_place_card_in_zone(dragged_card, dropped_zone)
					else:
						_animate_card_to_zone(dragged_card, dragged_card.resting_position)

				# End dragging
				if dragged_card.has_method("on_drag_end"):
					dragged_card.on_drag_end()
				dragged_card = null

	# 📌 Handle mouse movement while dragging
	if event is InputEventMouseMotion:
		# If we're dragging a card, update its position (already handled).
		if dragged_card:
			var new_position = get_viewport().get_mouse_position() + drag_offset
			dragged_card.global_position = new_position
		else:
			# Hover preview: update the card preview node.
			var hovered_card = _get_card_under_mouse()
			if hovered_card:
				# Assume the hovered card has a method get_card_data() that returns a dictionary.
				var data = hovered_card.get_card_data()  # e.g., {"title": "Flame Imp", "description": "...", "attack": "3", ...}
				# Update the preview node with the card's details.
				card_preview_node.set_card_data(data.title, data.description, data.attack, data.defense, data.cost)
				# Optionally, you might want to show the preview node if it was hidden.
				card_preview_node.show()
			else:
				# If no card is hovered, hide the preview.
				card_preview_node.hide()
			if hovered_card and (hovered_card in hand_manager_node.my_hand):
				if not hovered_card.has_meta("bumped") or hovered_card.get_meta("bumped") == false:
					hovered_card.set_meta("bumped", true)
					hovered_card.global_position = hovered_card.resting_position - Vector2(0, 10)
			for card in hand_manager_node.my_hand:
				if card != hovered_card:
					if card.has_meta("bumped") and card.get_meta("bumped") == true:
						card.set_meta("bumped", false)
						card.global_position = card.resting_position
	#if event is InputEventMouseMotion and dragged_card:
		#var new_position = get_viewport().get_mouse_position() + drag_offset
		#dragged_card.global_position = new_position

func _get_opponent_under_mouse():
	print("🔍 Checking for opponents under mouse...")
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_viewport().get_mouse_position()
	query.collide_with_areas = true
	query.collision_mask = 3  # Ensure opponent portrait is on layer 3

	var result = space_state.intersect_point(query)
	print("🔎 Found", result.size(), "objects under mouse.")

	for res in result:
		var node = res.collider
		# Skip nodes that are placement zones.
		if node.is_in_group("zones"):
			continue
		print("🧐 Opponent detected under mouse:", node.name)
		return node
	
	print("❌ No opponents under mouse.")
	return null

# Utility function to check for a card under the mouse.
func _get_card_under_mouse():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	# Using the current mouse position (adjust if using a different coordinate system)
	query.position = get_viewport().get_mouse_position()
	query.collide_with_areas = true
	query.collision_mask = 1  # Ensure your card collision layers match this
	
	var result = space_state.intersect_point(query)
	#print("Intersect point result size:", result.size())
	if result.size() > 0:
		# Assuming your card collision shape is inside a child (e.g. CardVisuals) and the card itself is the parent.
		var potential_card = result[0].collider.get_parent()
		#if potential_card:
			#print("Potential card found:", potential_card.name, "Groups:", potential_card.get_groups())
		if potential_card and potential_card.is_in_group("cards"):
			return potential_card
		else:
			pass
			#print("Potential card is not in group 'cards'")
	return null

func _get_zone_under_mouse():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_viewport().get_mouse_position()
	query.collide_with_areas = true
	query.collision_mask = 2  # Ensure zones are on collision layer 2

	var result = space_state.intersect_point(query)
	print("🔍 Zone Detection: Found", result.size(), "possible objects under mouse")

	if result.size() > 0:
		for res in result:
			var detected_node = res.collider  # Get the actual node
			print("➡️ Detected Object:", detected_node.name, "Type:", detected_node.get_class())

			# Ensure we're detecting an Area2D (which the zone should be)
			if detected_node is Area2D:
				var zone = detected_node  # The Area2D itself is the zone
				if zone.is_in_group("zones"):
					print("✅ Card is over a valid zone:", zone.zone_name)
					return zone
				else:
					print("⚠️ Detected Area2D but it's not in 'zones' group:", zone.name)
			else:
				print("❌ Detected object is not an Area2D, skipping:", detected_node.name)

	print("❌ No valid zone detected under mouse.")
	return null

func _place_card_in_zone(card, zone):
	print("🃏 Attempting to place", card.name, "into", zone.zone_name)

	# 📌 Check if zone belongs to the opponent
	if "Opponent" in zone.zone_name:
		print("❌ Cannot place cards into opponent's zone:", zone.zone_name)
		_animate_card_to_zone(card, card.resting_position)
		return

	# 📌 Check if card type matches zone type
	var card_type = card.get_meta("card_type")  # Make sure this metadata exists!
	var is_creature = (card_type == "Creature")

	if zone.is_creature_zone != is_creature:
		print("❌ Cannot place", card_type, "into", zone.zone_name)
		_animate_card_to_zone(card, card.resting_position)
		return
	
	if !turn_manager_node.is_player_turn:
		print("❌ Cannot place card on opponent turn")
		_animate_card_to_zone(card, card.resting_position)
		return
	
	if player_manager_node.player_mana < int(card.get_meta("card_mana_cost")):
		print("❌ Not enough mana to play", card.name)
		_animate_card_to_zone(card, card.resting_position)
		return  # Prevent placement if mana is insufficient.
	else:
		# Deduct mana and update the display.
		player_manager_node.player_mana -= int(card.get_meta("card_mana_cost"))
		player_manager_node.update_mana_display(false)
		
	# 📌 Passed checks, remove card from hand and place in zone
	card.trigger_ability("on_played")
	var hand_manager = hand_manager_node
	hand_manager.remove_card_from_hand(card)
	zone.add_card_to_zone(card)
	
	if card.get_meta("card_type") == "Spell":
		print('card.get_meta("card_type") == "Spell":', card.get_meta("card_type") == "Spell", "for Spell:", card.get_meta("card_type"))
		call_deferred("resolve_spell", card)


func _animate_card_to_zone(card, target_position: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", target_position, 0.4)
	card.update_resting_position(target_position)

func _swap_cards_in_hand(card1, card2):
	print("🔄 Swapping", card1.name, "and", card2.name, "in hand.")

	# Ensure both cards are in the player's hand
	if card1 in hand_manager_node.my_hand and card2 in hand_manager_node.my_hand:
		var index1 = hand_manager_node.my_hand.find(card1)
		var index2 = hand_manager_node.my_hand.find(card2)

		# Swap them in the array
		hand_manager_node.my_hand[index1] = card2
		hand_manager_node.my_hand[index2] = card1

		# Re-arrange cards with animation
		hand_manager_node.update_hand_positions()
	else:
		print("❌ Swap failed: One or both cards are not in your hand.")

func resolve_spell(card):
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout
	# After one second, move the card to the graveyard.
	# Replace "/root/Graveyard" with your actual graveyard NodePath.

	if graveyard_manager_node:
		graveyard_manager_node.add_to_graveyard(card)
		print("Spell resolved and sent to graveyard:", card.name)
		card.queue_free()
