extends Label

var score: int = 0


func _on_mob_squashed() -> void:
	score += 1
	text = "Score: %s" % score
