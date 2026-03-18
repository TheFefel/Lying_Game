extends RayCast3D

@onready var prompt: Label = $Prompt

var current_interactable: Interactable = null

func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	prompt.text = ""
	
	if is_colliding():
		var collider = get_collider()
		
		if collider is Interactable:
			
			prompt.text = collider.get_prompt()
			
			if collider != current_interactable:
				
				if current_interactable:
					current_interactable.unhighlight_interactable()
				
				current_interactable = collider
				current_interactable.highlight_interactable()
			
			if Input.is_action_just_pressed(collider.prompt_input):
				collider.interact(owner)
			
		else:
			clear_interactable()
	else:
		clear_interactable()

func clear_interactable():
	if current_interactable:
		current_interactable.unhighlight_interactable()
		current_interactable = null
