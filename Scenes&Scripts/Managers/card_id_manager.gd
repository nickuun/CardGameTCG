extends Node

var next_unique_id: int = 1  # Start unique IDs from 1

# Returns a new unique ID and increments the counter.
func get_new_card_id() -> int:
	var new_id = next_unique_id
	next_unique_id += 1
	# Optionally, broadcast the new ID to other clients here.
	return new_id

# Syncs the counter with an incoming card ID from the network.
func sync_card_id(received_id: int) -> void:
	if received_id >= next_unique_id:
		next_unique_id = received_id + 1
