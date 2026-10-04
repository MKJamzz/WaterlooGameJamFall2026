extends Node
@onready var quote: Label = $Quote
@onready var background_music: AudioStreamPlayer = $BackgroundMusic

var nightmareQuotes = ["You feel a chill through your spine...", 
						"Your heart begins to pound...",
						"The dream twists into something darker...",
						"You try to wake up. You can't...",
						"No one is coming to save you...",
						"Goosebumps crawl up your spine...",
						"Your hands wont stop shaking...",										
						"Every instinct tells you to run...",
						"A shiver runs down to your fingertips...",
						"There's nowhere left to hide...",
						"Your skin crawls..."									]

func chooseQuote() -> void:
	
	var nightmareQuotesIndex = randi_range(0, nightmareQuotes.size() - 1)
	var chosenQuote = nightmareQuotes[nightmareQuotesIndex]
	quote.text = chosenQuote
	

func _ready() -> void:
	chooseQuote()
	background_music.play()
