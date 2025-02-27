extends Node

var zones: Dictionary = {}  # Stores zones by name

func _ready():
	# Populate dictionary with zones
	for zone in get_tree().get_nodes_in_group("zones"):
		zones[zone.zone_name] = zone

func get_zone_by_name(zone_name: String):
	return zones.get(zone_name, null)
