extends Node2D

var graveyard_cards = []  # Stores removed card data
@export var graveyard_view: NodePath
@export var graveyard_pile: NodePath
@export var scroll_left_button: NodePath
@export var scroll_right_button: NodePath
@export var close_button: NodePath
@export var card_scene: PackedScene  # This will be used to re-create card instances when viewing

var graveyard_view_node = null
var graveyard_pile_node = null
var scroll_left_button_node = null
var scroll_right_button_node = null
var close_button_node = null
var current_index = 0
var viewed_card_instance = null  # The temporary card being viewed

func _ready():
	# Get UI elements
	graveyard_view_node = get_node(graveyard_view)
	graveyard_pile_node = get_node(graveyard_pile)
	scroll_left_button_node = get_node(scroll_left_button)
	scroll_right_button_node = get_node(scroll_right_button)
	close_button_node = get_node(close_button)

	# Hide the graveyard view initially
	graveyard_view_node.visible = false
	scroll_left_button_node.visible = false
	scroll_right_button_node.visible = false
	close_button_node.visible = false

	# Connect button signals
	graveyard_pile_node.connect("pressed", _on_graveyard_clicked)
	scroll_left_button_node.connect("pressed", _scroll_left)
	scroll_right_button_node.connect("pressed", _scroll_right)
	close_button_node.connect("pressed", _close_graveyard)

# 📌 Adds a card's metadata to the graveyard (instead of the node itself)
func add_to_graveyard(card):
	print("🪦 Sending", card.name, "to the graveyard")

	# Store only the relevant card data, NOT the full node
	var card_data = {
		"card_id": card.get_meta("card_id"),
		"card_title": card.get_meta("card_title"),
		"card_type": card.get_meta("card_type"),
		"card_description": card.get_meta("card_description"),
		"card_attack": card.get_meta("card_attack"),
		"card_defense": card.get_meta("card_defense"),
		"card_mana_cost": card.get_meta("card_mana_cost"),
		"abilities": card.get_meta("abilities")
	}
	for i in 5:
		graveyard_cards.push_front(card_data)  # FILO - newest cards at front
	card.queue_free()  # Free the original card
	update_graveyard_display()

# 📌 Updates how the graveyard looks when not in view mode
func update_graveyard_display():
	if graveyard_cards.is_empty():
		graveyard_pile_node.visible = false
	else:
		graveyard_pile_node.visible = true  # Show pile when cards exist

# 📌 Opens the graveyard view
func _on_graveyard_clicked():
	if graveyard_cards.is_empty():
		print("⚰️ Graveyard is empty!")
		return

	graveyard_view_node.visible = true
	scroll_left_button_node.visible = true
	scroll_right_button_node.visible = true
	close_button_node.visible = true
	current_index = 0
	_display_graveyard_cards()

# 📌 Displays the currently selected card in view mode

func _display_graveyard_cards():
	# Remove previously displayed cards
	for child in graveyard_view_node.get_children():
		if not child.is_in_group("graveyard_ui"):
			child.queue_free()

	# Determine max cards to show in a fan (5 max at a time)
	var max_display = min(5, graveyard_cards.size())  
	var start_index = max(0, graveyard_cards.size() - max_display)

	for i in range(max_display):
		var card_data = graveyard_cards[start_index + i]
		var card_instance = card_scene.instantiate()

		# Set up the card with stored metadata
		card_instance.flip_card()
		card_instance.set_card(
			card_data["card_id"],
			card_data["card_title"],
			card_data["card_type"],
			card_data["card_description"],
			card_data["card_attack"],
			card_data["card_defense"],
			card_data["card_mana_cost"],
			card_data["abilities"]
		)

		# Calculate position in the fan layout
		var offset_x = i * 80  # Spread out horizontally
		var offset_y = abs(i - max_display / 2) * 10  # Slight curve effect

		card_instance.position = graveyard_view_node.position + Vector2(offset_x, -offset_y)
		card_instance.rotation_degrees = -10 + i * 5  # Fan-like rotation effect

		# Add to the graveyard view
		graveyard_view_node.add_child(card_instance)

		# Make the top card (newest) fully visible
		if i == max_display - 1:
			card_instance.scale = Vector2(1.2, 1.2)  # Slight enlargement
		else:
			card_instance.scale = Vector2(1.0, 1.0)

	print("👀 Viewing graveyard with", max_display, "cards fanned out.")

func _scroll_left():
	if graveyard_cards.size() > 5:
		graveyard_cards.push_back(graveyard_cards.pop_front())  # Move first to last
		_display_graveyard_cards()

func _scroll_right():
	if graveyard_cards.size() > 5:
		graveyard_cards.push_front(graveyard_cards.pop_back())  # Move last to first
		_display_graveyard_cards()
	else:
		print("graveyard too small")

# 📌 Closes the graveyard view
func _close_graveyard():
	graveyard_view_node.visible = false
	scroll_left_button_node.visible = false
	scroll_right_button_node.visible = false
	close_button_node.visible = false

	# Free the last viewed card
	if viewed_card_instance:
		viewed_card_instance.queue_free()
		viewed_card_instance = null

	update_graveyard_display()  # Restore pile view
