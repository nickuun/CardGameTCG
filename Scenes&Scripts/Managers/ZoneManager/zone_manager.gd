extends Node

var zones: Dictionary = {} 

func _ready():
	# Populate dictionary with zones
	for zone in get_tree().get_nodes_in_group("zones"):
		zones[zone.zone_name] = zone

func get_zone_by_name(zone_name: String):
	print("got zone by name", zone_name)
	return zones.get(zone_name, null)
	
func refresh_exhausted(is_opponent: bool):
	var zone_name = "Opponent Monster Zone" if is_opponent else "Player Monster Zone"

	var zone = get_zone_by_name(zone_name)
	if zone:
		for card in zone.cards_in_zone:
			card.set_exhausted(false)
	else:
		print("⚠️ Zone not found:", zone_name)
