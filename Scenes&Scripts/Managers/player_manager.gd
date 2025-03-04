extends Node

@export var player_health: int = 20
@export var opponent_health: int = 20
@export var player_mana: int = 0
@export var player_max_mana: int = 0
@export var opponent_mana: int = 0
@export var opponent_max_mana: int = 0
@export var player_name: String = "Player"
@export var opponent_name: String = "Opponent"

@export var player_healthbar: NodePath
@export var opponent_healthbar: NodePath
@export var player_manabar: NodePath
@export var opponent_manabar: NodePath

var player_healthbar_node = null
var opponent_healthbar_node = null
var player_manabar_node = null
var opponent_manabar_node = null

@export var mana_sprite_size: int = 26 

func _ready():

	if player_healthbar:
		player_healthbar_node = get_node(player_healthbar)
		setup_health_bar(player_healthbar_node, player_health)
	if opponent_healthbar:
		opponent_healthbar_node = get_node(opponent_healthbar)
		setup_health_bar(opponent_healthbar_node, opponent_health)
	if player_manabar:
		player_manabar_node = get_node(player_manabar)
		update_mana_display(false)
	if opponent_manabar:
		opponent_manabar_node = get_node(opponent_manabar)
		update_mana_display(true)

func update_mana_display(is_opponent: bool):
	var mana_bar = opponent_manabar_node if is_opponent else player_manabar_node
	var current_mana = opponent_mana if is_opponent else player_mana
	var max_mana = opponent_max_mana if is_opponent else player_max_mana
	if mana_bar:
		var filled = mana_bar.get_node("Filled")
		var empty = mana_bar.get_node("Empty")

		if current_mana == 0:
			filled.visible = false
		else:
			filled.visible = true
			filled.size.x = mana_sprite_size * current_mana
		
		empty.size.x = mana_sprite_size * max_mana

func subtract_mana(amount: int, is_opponent: bool = false) -> void:
	if is_opponent:
		opponent_mana = max(0, opponent_mana - amount)
		update_mana_display(true)
		print("Opponent mana decreased by", amount, "New mana:", opponent_mana)
	else:
		player_mana = max(0, player_mana - amount)
		update_mana_display(false)
		print("Player mana decreased by", amount, "New mana:", player_mana)

func setup_health_bar(healthbar, max_health):
	healthbar.max_value = max_health  # Set max HP
	healthbar.value = max_health  # Start at full health
	_update_health_label(healthbar)

func modify_health(is_opponent: bool, amount: int):
	if is_opponent:
		opponent_health = max(0, opponent_health + amount)
		# If healing and new health is greater than the current max_value, update it
		if amount > 0 and opponent_health > opponent_healthbar_node.max_value:
			opponent_healthbar_node.max_value = opponent_health
		print("💥 Opponent health modified by", amount, "- New HP:", opponent_health)
		update_health_display(true)
	else:
		player_health = max(0, player_health + amount)
		# If healing and new health is greater than the current max_value, update it
		if amount > 0 and player_health > player_healthbar_node.max_value:
			player_healthbar_node.max_value = player_health
		print("💥 Player health modified by", amount, "- New HP:", player_health)
		update_health_display(false)

	# Check for game over
	if player_health <= 0:
		print("💀 Player has lost the game!")
	if opponent_health <= 0:
		print("💀 Opponent has lost the game!")

func update_health_display(is_opponent: bool):
	var healthbar = opponent_healthbar_node if is_opponent else player_healthbar_node
	if healthbar:
		healthbar.value = opponent_health if is_opponent else player_health
		_update_health_label(healthbar)

func _update_health_label(healthbar):
	var label = healthbar.get_parent().get_node("Label") if healthbar.get_parent().has_node("Label") else null
	if label:
		label.text = str(healthbar.value)  # Display current HP as text
	#healthbar.get_node("TextureProgressBar") needs to work with max_value
