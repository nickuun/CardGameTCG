extends Node

@export var player_manager: NodePath
@export var card_manager: NodePath

var player_manager_node = null
var card_manager_node = null

var pending_ability = null

func _ready() -> void:
	if player_manager:
		player_manager_node = get_node(player_manager)
	if card_manager:
		card_manager_node = get_node(card_manager)

# 📌 Define available abilities
var abilities = {
	"boost_attack": func(card): boost_attack(card),
	"heal_all_allies": func(card): heal_all_allies(card),
	"deal_damage_to_hero": func(card, amount := 1): deal_damage_to_hero(card, amount),
	"give_target_buff": func(source_card, param := 1): give_target_buff(source_card, param),
	"turn_into_2_2_wolf": func(source_card): turn_into_2_2_wolf(source_card),
	"gain_life": func(card): gain_life(card),
	"defence_up": func(card, amount := 2): defence_up(card, amount),
	"buff_self": func(card, amount := 1): buff_self(card, amount),
	"attack_up": func(card, amount := 1): attack_up(card, amount),
	"both_gain_life": func(card, amount := 1): both_gain_life(card, amount),
	"draw_card": func(card, amount := 1): draw_card(card, amount),
	"deal_damage_to_self": func(card, amount := 1): deal_damage_to_self(card, amount),
	"attack_up_allies": func(card, amount := 1): attack_up_allies(card, amount),
	"damage_creatures": func(card, amount := 1): damage_creatures(card, amount)
}

func trigger_abilities(card, trigger_type):
	if not card.has_meta("abilities"):
		return

	var ability_list = card.get_meta("abilities")
	for ability in ability_list:
		if ability["trigger"] == trigger_type:
			var raw_function_string = ability["function"] 
			var parsed = _parse_function_string(raw_function_string)  # from earlier snippet
			var function_name = parsed["name"]  
			var arg = parsed["arg"]  

			if function_name == "give_target_buff" or function_name == "turn_into_2_2_wolf":
				# Instead of calling it immediately, request a target:
				var param = arg if arg != null else 1
				request_target_for_ability(card, function_name, param)
			else:
				# Normal path for abilities that don't need a target
				if function_name in abilities:
					if arg == null:
						abilities[function_name].call(card)
					else:
						abilities[function_name].call(card, arg)


func _parse_function_string(func_string: String) -> Dictionary:
	# Example: "deal_damage_to_hero(2)" => { "name": "deal_damage_to_hero", "arg": 2 }
	#          "deal_damage_to_hero"    => { "name": "deal_damage_to_hero", "arg": null }

	var open_paren = func_string.find("(")
	if open_paren == -1:
		# No parentheses => no argument
		return {"name": func_string, "arg": null}

	var close_paren = func_string.find(")", open_paren)
	if close_paren == -1:
		# Malformed => ignore parentheses
		return {"name": func_string, "arg": null}

	var name_only = func_string.substr(0, open_paren).strip_edges()
	var arg_string = func_string.substr(open_paren + 1, close_paren - open_paren - 1).strip_edges()

	# Try to parse the argument as an integer (you could expand for multiple or different types)
	var arg_value = arg_string.to_int()

	return {"name": name_only, "arg": arg_value}

func request_target_for_ability(source_card, function_name, param := 1):
	# This function sets up the pending ability data so the game knows
	# we need to pick a target.
	$CardTitleLabel.show()
	pending_ability = {
		"source_card": source_card,
		"function_name": function_name,
		"param": param
	}
	print("🎯 Please select a target for ability:", function_name)

func apply_pending_ability_to_target(target_card):
	$CardTitleLabel.hide()
	if not pending_ability:
		return  # No pending ability

	var fn = pending_ability.function_name
	var source_card = pending_ability.source_card
	var param = pending_ability.param

	# For “give_target_buff”, actually apply the effect here
	if fn == "give_target_buff":
		print("💪 Applying 'give_target_buff' from", source_card.name, "to", target_card.name)
		# Increase target's attack and defense by param
		var old_attack = target_card.get_meta("card_attack")
		var old_defense = target_card.get_meta("card_defense")
		target_card.set_meta("card_attack", str(int(old_attack) + param))
		target_card.set_meta("card_defense", str(int(old_defense) + param))
		target_card.update_card_stat_visuals()
		print("   Attack:", old_attack, "→", str(int(old_attack) + param),
			  "   Defense:", old_defense, "→", str(int(old_defense) + param))
	elif fn == "turn_into_2_2_wolf":
		print("🐺 Applying 'turn_into_2_2_wolf' from", target_card.name)
		turn_into_2_2_wolf(target_card)
	else:
		# Or if other abilities also needed a target, handle them here
		if fn in abilities:
			# Some abilities might still need the target as first arg
			abilities[fn].call(source_card, param)

	# Clear the pending ability
	pending_ability = null

# 📌 Ability Effects

func defence_up(card, amount := 2):
	print("🛡️", card.name, "defence increased by", amount)
	var old_def = int(card.get_meta("card_defense"))
	card.set_meta("card_defense", str(old_def + amount))
	card.update_card_stat_visuals()

func buff_self(card, amount := 1):
	print("🔥", card.name, "buffing itself by +", amount, "attack and defense")
	var old_attack = int(card.get_meta("card_attack"))
	var old_def = int(card.get_meta("card_defense"))
	card.set_meta("card_attack", str(old_attack + amount))
	card.set_meta("card_defense", str(old_def + amount))
	card.update_card_stat_visuals()

func attack_up(card, amount := 1):
	print("⚔️", card.name, "attack increased by", amount)
	var old_attack = int(card.get_meta("card_attack"))
	card.set_meta("card_attack", str(old_attack + amount))
	card.update_card_stat_visuals()
	
func both_gain_life(card, amount := 1):
	print("❤️ Both players gain", amount, "life due to", card.name)
	# Increase both players' health. Adjust these calls as needed.
	player_manager_node.modify_health(false, amount)  # Player gains life.
	player_manager_node.modify_health(true, amount)   # Opponent gains life.

func draw_card(card, amount := 1):
	var owner = card.get_meta("owner")
	print("📚", card.name, "triggers drawing", amount, "card(s)")
	if owner == "player":
		card_manager_node.draw_card()
	else:
		card_manager_node.draw_card_opponent()

func deal_damage_to_self(card, amount := 1):
	var owner = card.get_meta("owner")
	print("💥", card.name, "deals", amount, "damage to its owner's hero")
	if owner == "player":
		player_manager_node.modify_health(false, -amount)
	else:
		player_manager_node.modify_health(true, -amount)
		
func attack_up_allies(card, amount := 1):
	print("⚔️", card.name, "buffs all allies' attack by", amount)
	# Assuming you have a ZoneManager to get player's battlefield cards.
	#var zone_manager = get_node("/root/ZoneManager")  # Adjust the path accordingly.
	#for ally in zone_manager.get_player_battlefield_cards():
		#if ally != card:
			#var old_attack = int(ally.get_meta("card_attack"))
			#ally.set_meta("card_attack", str(old_attack + amount))
			#ally.update_card_stat_visuals()

func damage_creatures(card, amount := 1):
	print("💥", card.name, "damages all creatures by", amount)
	# Loop through all cards (assuming they are in a "cards" group)
	#for c in get_tree().get_nodes_in_group("cards"):
		#var old_def = int(c.get_meta("card_defense"))
		#c.set_meta("card_defense", str(old_def - amount))
		#c.update_card_stat_visuals()

func heal_all_allies(card):
	print("❤️ Healing all allies by +1 HP")
	# loop through ally creatures and increase HP
	
func on_kill_draw_card(card):
	print("📚", card.name, "kills a creature and draws a card")
	# Implement draw logic here. For now, just print.

func boost_attack(card):
	print("🛡️ Boosting attack of", card.name)
	card.set_meta("attack", int(card.get_meta("attack")) + 1)
	card.update_card_stat_visuals()

func gain_life(card):
	var owner = card.get_meta("owner")
	print("❤️ Gaining 1 life due to 'gain_life' ability on", card.name)
	if owner == "player":
		player_manager_node.modify_health(false, 1)
	else:
		player_manager_node.modify_health(true, 1)

#func deal_damage_to_hero(card, amount := 1):
	#print("💥 Dealing %s damage to enemy hero" % amount)
	#player_manager_node.modify_health(true, -amount)

func deal_damage_to_hero(card, amount := 1):
	print("💥 Dealing %s damage to enemy hero" % amount)
	var zone = card.get_meta("current_zone")
	if zone.find("Opponent") != -1:
		player_manager_node.modify_health(false, -amount)
	else:
		player_manager_node.modify_health(true, -amount)

func give_target_buff(source_card, param := 1):
	# We'll apply this later once we know the target
	# So for now, we just store it here.
	print("💪 'give_target_buff' was called but needs a target! (No direct effect yet)")

func turn_into_2_2_wolf(target_card):
	print("🐺 Turning", target_card.name, "into a 2/2 Wolf")
	var cost = target_card.get_meta("card_mana_cost")
	# Preserve the card's id and cost, change other meta data:
	target_card.set_meta("card_title", "Small Wolf")
	target_card.set_meta("abilities", "")
	target_card.set_meta("card_description", "")
	target_card.set_meta("card_attack", "2")
	target_card.set_meta("card_defense", "2")
	# Update visuals (assuming your card has a CardVisuals child node named "CardVisuals")
	target_card.update_card_stat_visuals()
	target_card.update_card_hero()
