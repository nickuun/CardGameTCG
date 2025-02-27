extends Node

@export var zone_manager_path: NodePath
@export var hand_manager_path: NodePath
@export var player_manager_path: NodePath
@export var graveyard_manager_path: NodePath

var zone_manager = null
var hand_manager = null
var player_manager = null
var graveyard_manager = null

var attacking_card = null  # Stores the attacking card while dragging

func _ready():
	zone_manager = get_node(zone_manager_path)
	hand_manager = get_node(hand_manager_path)
	player_manager = get_node(player_manager_path)
	graveyard_manager = get_node(graveyard_manager_path)

# 📌 Called when the player starts dragging an attack
func start_attack(card):
	if attacking_card == card:
		print("❌ Already selecting this attacker!")
		return

	# 📌 Allow changing the attacker by clicking another one
	if attacking_card:
		print("🔄 New attacker selected:", card.name)
	else:
		print("⚔️ Attacker selected:", card.name)

	attacking_card = card

# 📌 Called when the player releases the attack on a target
func attempt_attack(target_card):
	if not attacking_card:
		print("❌ No attacker selected!")
		return

	# Ensure we are attacking an opponent's monster
	var attacker_zone = attacking_card.get_meta("current_zone")
	var target_zone = target_card.get_meta("current_zone")

	if not target_zone or "Opponent" not in target_zone:
		print("❌ Can only attack opponent monsters!")
		attacking_card = null
		return

	print("🔥 Combat: ", attacking_card.name, "attacks", target_card.name)
	apply_combat(attacking_card, target_card)
	attacking_card = null  # Reset after attack

# 📌 Applies combat mechanics
func apply_combat(attacker, defender):
	attacker.trigger_ability("on_attack")
	
	var attacker_attack = float(attacker.get_meta("card_attack"))
	var defender_attack = float(defender.get_meta("card_attack"))
	var defender_health = float(defender.get_meta("card_defense"))
	var attacker_health = float(attacker.get_meta("card_defense"))

	# Apply damage
	attacker_health -= defender_attack
	defender_health -= attacker_attack

	# Play animations
	attacker.play_attack_animation()
	defender.play_defend_animation()

	# Check if attacker dies
	if attacker_health <= 0:
		print("💀", attacker.name, "was destroyed!")
		attacker.play_death_animation()
		attacker.trigger_ability("on_death")
		graveyard_manager.add_to_graveyard(attacker)
		zone_manager.get_zone_by_name(attacker.get_meta("current_zone")).remove_card_from_zone(attacker)

	# Check if defender dies
	if defender_health <= 0:
		print("💀", defender.name, "was destroyed!")
		defender.play_death_animation()
		defender.trigger_ability("on_death")
		graveyard_manager.add_to_graveyard(defender)
		zone_manager.get_zone_by_name(defender.get_meta("current_zone")).remove_card_from_zone(defender)

	# Update health stats on cards
	attacker.set_meta("card_defense", str(attacker_health))
	defender.set_meta("card_defense", str(defender_health))

func direct_attack():
	if not attacking_card:
		print("❌ No attacker selected!")
		return

	print("⚔️", attacking_card.name, "attacks opponent directly!")
	
	var attack_value = attacking_card.get_meta("card_attack")

	if attack_value == null or not attack_value.is_valid_int():
		print("❌ Error: Attack value is invalid for", attacking_card.name, ":", attack_value)
		return  # Stop execution if attack is invalid

	player_manager.modify_health(true, -int(attack_value))

	# Play attack animation
	attacking_card.play_attack_animation()

	# Reset attacker
	attacking_card = null
