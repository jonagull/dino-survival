extends Node

var InstructionSet = load("res://scripts/InstructionSet.gd")

# Parse a given input string into an instruction.
func parse(text):
	match text:
		'go north':
			return InstructionSet.NORTH
		'north':
			return InstructionSet.NORTH
		'go south':
			return InstructionSet.SOUTH
		'south':
			return InstructionSet.SOUTH
		'go east':
			return InstructionSet.EAST
		'east':
			return InstructionSet.EAST
		'go west':
			return InstructionSet.WEST
		'west':
			return InstructionSet.WEST

	return InstructionSet.NOT_FOUND

# func get_object():
# 	return object
