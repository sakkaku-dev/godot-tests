extends Node

var is_hacker := false
var seed := 0
var money_in_millions := 0

var logger := KumaLog.new("Heist")

func generate_new():
	seed = randi()
	logger.info("Generated new heist with seed %d" % seed)
	return seed
