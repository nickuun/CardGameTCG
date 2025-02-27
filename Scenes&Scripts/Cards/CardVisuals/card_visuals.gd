extends Node2D
#class_name CardVisuals

@onready var card_base = $CardBaseSprite
@onready var title_label = $CardTitleLabel
@onready var description_label = $CardDescriptionLabel
#@onready var attack_label = $Attack
#@onready var defense_label = $Defence
#@onready var cost_label = $CostLabel
#@onready var icon_sprite = $CardIcon
@onready var hero_art = $CardHeroSprite

# Update visuals
func set_card_data(title: String, description: String, attack: String, defense: String, cost: String):
	
	$CardTitleLabel.text = title
	$CardHeroSprite.play(title)
	$CardDescriptionLabel.text = description
	if defense != "-":
		$DefenceLabel.text = defense
	else:
		$DefenceLabel.hide()
	if attack != "-":
		$AttackLabel.text = attack
	else:
		$AttackLabel.hide()
	
	$CardManaCost.text = cost
	
	#attack_label.text = attack
	#attack_label.visible = attack != "-"

	#defense_label.text = defense
	#defense_label.visible = defense != "-"

	#cost_label.text = cost

	#icon_sprite.play(icon)
	#hero_art.play(title)
