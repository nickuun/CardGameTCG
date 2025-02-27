extends Node
#class_name CardLogic

var dragging := false
var mouse_offset := Vector2.ZERO
var parent_card: Node2D  # Reference to the card

func setup(card: Node2D):
	parent_card = card  # Store reference to the parent card
	print("set up")
#
#func _input_event(viewport, event):
	#print("input")
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#dragging = event.pressed
		#mouse_offset = parent_card.position - parent_card.get_global_mouse_position()
#
#func _input(event):
	#print("other input")
	#
	#if dragging and event is InputEventMouseMotion:
		#parent_card.position = parent_card.get_global_mouse_position() + mouse_offset
