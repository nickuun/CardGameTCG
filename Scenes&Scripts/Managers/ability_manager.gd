extends Node

@export var player_manager: NodePath
var player_manager_node = null

func _ready() -> void:
	if player_manager:
		player_manager_node = get_node(player_manager)

# 📌 Define available abilities
var abilities = {
	"boost_attack": func(card): boost_attack(card),
	"heal_all_allies": func(card): heal_all_allies(card),
	"deal_damage_to_hero": func(card, amount := 1): deal_damage_to_hero(card, amount)
}

# 📌 Call all matching abilities for a given trigger
func trigger_abilities(card, trigger_type):
	print("Triggered Ability Manager")
	if not card.has_meta("abilities"):
		return

	var ability_list = card.get_meta("abilities")  # e.g. [{"trigger":"on_played","function":"deal_damage_to_hero(2)"}]
	for ability in ability_list:
		if ability["trigger"] == trigger_type:
			var raw_function_string = ability["function"]  # e.g. "deal_damage_to_hero(2)"
			var parsed = _parse_function_string(raw_function_string)
			var function_name = parsed["name"]         # "deal_damage_to_hero"
			var arg = parsed["arg"]                    # 2 or null

			if function_name in abilities:
				print("✨ Ability triggered:", raw_function_string, "for", card.name)
				if arg == null:
					# No parentheses => default param
					abilities[function_name].call(card)
				else:
					# Found an integer argument
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

# 📌 Ability Effects
func boost_attack(card):
	print("🛡️ Boosting attack of", card.name)
	card.set_meta("attack", int(card.get_meta("attack")) + 1)
	card.update_card_stat_visuals()

func heal_all_allies(card):
	print("❤️ Healing all allies by +1 HP")
	# loop through ally creatures and increase HP

func deal_damage_to_hero(card, amount := 1):
	print("💥 Dealing %s damage to enemy hero" % amount)
	player_manager_node.modify_health(true, -amount)
