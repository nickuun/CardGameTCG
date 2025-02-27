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
	"deal_damage_to_hero": func(card): deal_damage_to_hero(card)
}

# 📌 Call all matching abilities for a given trigger
func trigger_abilities(card, trigger_type):
	print("Triggered Ability Manager")
	if not card.has_meta("abilities"):
		return  # No abilities on this card

	var ability_list = card.get_meta("abilities")  # Get list of abilities
	for ability in ability_list:
		if ability["trigger"] == trigger_type:
			var function_name = ability["function"]
			if function_name in abilities:
				print("✨ Ability triggered:", function_name, "for", card.name)
				abilities[function_name].call(card)

# 📌 Ability Effects
func boost_attack(card):
	print("🛡️ Boosting attack of", card.name)
	card.set_meta("attack", int(card.get_meta("attack")) + 1)

func heal_all_allies(card):
	print("❤️ Healing all allies by +1 HP")
	# You would loop through ally creatures and increase HP

func deal_damage_to_hero(card):
	print("💥 Dealing 1 damage to enemy hero")
	player_manager_node.modify_health(true, -1)
