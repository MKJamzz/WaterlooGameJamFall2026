extends Node
@onready var quote: Label = $Quote
@onready var background_music: AudioStreamPlayer = $BackgroundMusic

var dreamQuotes = 		["You feel safe here...", 
						"Everything is going to be okay...",
						"Every breath feels easy...",
						"You could stay here forever...",
						"Sweet dreams...",
						"Your heart feels full...",
						"Courage fills you from head to toe...",										
						"A gentle calm washes over you...",
						"You believe in yourself a little more...",
						"The future feels a little brighter...",
						"You feel wrapped in a soft blanket..."									]

func chooseQuote() -> void:
	
	var dreamQuotesIndex = randi_range(0, dreamQuotes.size() - 1)
	var chosenQuote = dreamQuotes[dreamQuotesIndex]
	quote.text = chosenQuote
	

func _ready() -> void:
	chooseQuote()
	background_music.play()
	
