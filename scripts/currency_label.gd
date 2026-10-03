extends Label

func _ready() -> void:
	RunDataState.currency_changed.connect(_on_currency_changed)
	_on_currency_changed(RunDataState.currency)  # show the starting value

func _on_currency_changed(amount: int) -> void:
	text = str(amount)
