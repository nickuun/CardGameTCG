extends Node

# Dictionary to store card data from CSV. Keys are strings.
var card_data: Dictionary = {}

# Path to your CSV file (adjust as needed)
const CSV_PATH = "res://Scenes&Scripts/Cards/CardDatabase/Data/CardData - Cards.csv"

func _ready():
	load_cards_from_csv()

# Loads card data from CSV
func load_cards_from_csv() -> void:
	var file = FileAccess.open(CSV_PATH, FileAccess.READ)
	if file:
		print("📜 Loading card data from CSV...")
		var line_count = 0
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line.is_empty():
				continue
			# Remove unwanted quotes (Google Sheets may add these)
			var clean_line = line.replace('"', "")
			var columns = clean_line.split(",")
			# Ensure there are at least 8 columns (ID, Name, Type, Description, Attack, Defense, Cost, Abilities)
			if columns.size() < 8:
				print("⚠️ Skipping malformed line:", line)
				continue

			var card_id = columns[0].strip_edges()
			
			var raw_abilities = columns[7].strip_edges()
			
			
			var abilities_array: Array = []

			if raw_abilities != "":
				# Split the cell by the pipe to separate multiple abilities.
				var abilities_entries = raw_abilities.split("|")
				for ability_entry in abilities_entries:
					# Split each ability entry by colon to get trigger and function.
					var parts = ability_entry.split(":")
					if parts.size() >= 2:
						abilities_array.append({
							"trigger": parts[0].strip_edges(),
							"function": parts[1].strip_edges()
						})
					else:
						print("⚠️ Malformed ability entry for card", card_id, ":", ability_entry)
						# Optionally, skip or handle errors here.
			else:
				abilities_array = []  # No abilities
			
			
			card_data[card_id] = {
				"id": card_id,
				"title": columns[1].strip_edges(),
				"type": columns[2].strip_edges(),
				"description": columns[3].strip_edges(),
				"attack": columns[4].strip_edges(),
				"defense": columns[5].strip_edges(),
				"cost": columns[6].strip_edges(),
				"abilities": abilities_array
			}
			line_count += 1
			print("✅ Loaded card", card_data[card_id])
			
		file.close()
		print("✅ Loaded", line_count, "cards successfully!")
	else:
		print("❌ Failed to open card CSV file.")

# Lookup function: get a card by its ID
func get_card(card_id: String) -> Dictionary:
	if card_data.has(card_id):
		return card_data[card_id]
	else:
		print("⚠️ Card not found:", card_id)
		return {}

# (Optional) A lookup function that accepts an int ID (by converting to string)
func get_card_by_id(card_id: int) -> Dictionary:
	return get_card(str(card_id))
