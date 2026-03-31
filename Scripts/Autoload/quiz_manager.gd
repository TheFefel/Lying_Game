extends Node

var questions = []

func _ready() -> void:
	if multiplayer.is_server(): # important, so only the server loads questions
		load_questions()

# Read the questions and answers from the JSON file
func load_questions():
	var file  = FileAccess.open("res://Assets/Data/Questions.json", FileAccess.READ)
	
	if file == null:
		push_error("Couldn't open questions file")
		return
	
	var content = file.get_as_text()
	parse_questions(content)

# Parse through the JSON file if available and put valid questions in array
func parse_questions(content):
	var data = JSON.parse_string(content)
	
	if data == null:
		push_error("Couldn't parse JSON")
		return
	
	for q in data:
		if not q.has("question") or not q.has("answer"):
			push_error("Found invalid question")
			continue
		
		questions.append(q)

# Start the quiz by displaying the first question
func start_quiz():
	var question = questions[0] # Get question and answer of said index
	print(question)
	print(question["question"]) # Only get question (of index)
	print(question["answer"]) # Only get answer (of index)
