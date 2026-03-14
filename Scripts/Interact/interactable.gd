extends CollisionObject3D
class_name Interactable

signal interacted(body)

@export var prompt_message: String = "Interact"
@export var prompt_input: StringName = "interact"

func get_prompt():
	var key_name = ""
	for action in InputMap.action_get_events(prompt_input):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break
		elif action is InputEventMouseButton:
			key_name = action.as_text()
			break
	
	return "[" + key_name + "]" + prompt_message

func interact(body):
	interacted.emit(body)
