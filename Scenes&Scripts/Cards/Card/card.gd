extends Node2D
#class_name Card

@onready var visuals = $CardVisuals
@onready var logic = $CardLogic
var resting_position: Vector2 = Vector2.ZERO

var card_id # ID IN DATABASE, NOT 'UNIQUE ID'
var card_title
var card_type
var card_description
var card_attack
var card_defense
var card_mana_cost

# (Optional) Signal to notify when dragging starts or ends.
signal drag_started
signal drag_ended

func _ready():
	logic.setup(self)  # Let the logic script reference this card

func set_card(id, title: String, type: String,  description: String, attack: String, defense: String, cost: String, abilities: Array = []):
	print("Calling set card")
	set_meta("current_zone", "Hand")  # Default to "Hand" when first created

	$CardVisuals.set_card_data(title, description, attack, defense, cost)
		
	set_meta("card_id", id)
	card_id = id
	set_meta("card_title", title)
	card_title = title
	self.name = card_title
	set_meta("card_type", type)
	card_type = type
	set_meta("card_description", description)
	card_description = description
	set_meta("card_attack", attack)
	card_attack = attack
	set_meta("card_defense", defense)
	card_defense = defense
	set_meta("card_mana_cost", cost)
	card_mana_cost = cost
	set_meta("abilities", abilities)

func update_resting_position(new_position: Vector2) -> void:
	resting_position = new_position

# This function can be called from the DragManager.
func on_drag_start() -> void:
	# e.g., raise the card or change appearance.
	emit_signal("drag_started")
	# You could also call your visuals to change (like apply a shader or animation).
	pass

func on_drag_end() -> void:
	# Reset position or perform snap-to-grid logic.
	emit_signal("drag_ended")
	pass

func play_attack_animation():
	print("⚔️", name, "attacks!")
	var tween = get_tree().create_tween()
	var start_pos = position
	var attack_pos = position + Vector2(20, 0)  # Slight forward movement
	tween.tween_property(self, "position", attack_pos, 0.2)
	await get_tree().create_timer(0.2).timeout
	tween.tween_property(self, "position", start_pos, 0.2)

func play_defend_animation():
	print("🛡️", name, "defends!")
	var tween = get_tree().create_tween()
	var start_pos = position
	var defend_pos = position - Vector2(10, 0)  # Slight backward movement
	tween.tween_property(self, "position", defend_pos, 0.2)
	await get_tree().create_timer(0.2).timeout
	tween.tween_property(self, "position", start_pos, 0.2)

func play_death_animation():
	print("💀", name, "is destroyed!")
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)  # Fade out
	await get_tree().create_timer(0.5).timeout
	queue_free()  # Remove card

func trigger_ability(trigger_type):
	var ability_manager = get_tree().get_first_node_in_group("AbilityManager")
	if ability_manager:
		ability_manager.trigger_abilities(self, trigger_type)

func get_card_data() -> Dictionary:
	return {
		"title": card_title,
		"description": card_description,
		"attack": card_attack,
		"defense": card_defense,
		"cost": card_mana_cost
	}
