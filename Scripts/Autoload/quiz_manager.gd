extends Node

signal question_received(question_data)
signal answers_received(answers_data)

var questions = []
var remaining_questions = []
var current_question_pair
var current_question
var current_answer
var answers: Dictionary = {}
var total_players = 0

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
	#var question = questions[0]: Get question and answer of said index
	#print(question)
	#print(question["question"]): Only get question (of index)
	#print(question["answer"]): Only get answer (of index)
	if multiplayer.is_server():
		total_players = multiplayer.get_peers().size() + 1
		remaining_questions = questions.duplicate()
		remaining_questions.shuffle()
		
		current_question_pair = choose_next_question()
		current_question = current_question_pair["question"]
		current_answer = current_question_pair["answer"]
		print("Current question: %s" % current_question)
		receive_question.rpc(current_question)
		answers[0] = current_answer

# Choose the next question + answer
func choose_next_question():
	if remaining_questions.is_empty():
		print("No remaining questions")
		return null
	
	return remaining_questions.pop_front()

@rpc("authority", "call_local", "reliable")
func receive_question(question_data):
	question_received.emit(question_data)
	print("Emitted question_received with: %s" % question_data)

@rpc("any_peer", "call_local", "reliable")
func submit_answer(player_id, answer):
	answers[player_id] = answer
	
	# Check if all answers have been collected; -1 because of the right answer we added before
	if (answers.size() - 1) == total_players: 
		receive_answers.rpc(answers, current_question)

@rpc("authority", "call_local", "reliable")
func receive_answers(answers_data, question):
	answers_received.emit.call_deferred(answers_data, question) # call_deferred important because of the timing
	print("Emitted answers_received")
