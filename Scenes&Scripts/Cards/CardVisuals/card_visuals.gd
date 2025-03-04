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
		$DefenceLabel.show()
	else:
		$DefenceLabel.hide()
	if attack != "-":
		$AttackLabel.text = attack
		$AttackLabel.show()
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

func update_card_stat_visuals():
	$DefenceLabel.text = str(self.get_parent().get_meta("card_defense"))
	if $DefenceLabel.visible == false:
		$DefenceLabel.show()
	$AttackLabel.text = str(self.get_parent().get_meta("card_attack"))
	if $AttackLabel.visible == false:
		$AttackLabel.show()

func update_card_hero():
	$CardDescriptionLabel.text = str(self.get_parent().get_meta("card_description"))
	$CardHeroSprite.play(self.get_parent().get_meta("card_title"))

func set_exhausted(ex: bool = true):
	print("set_exhausted in card visuals")
	if ex:
		$ExhaustedIcon.show()
	else:
		$ExhaustedIcon.hide()
		
