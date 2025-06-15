extends Node

func sleep():
	process_data()

func process_data():
	for node in get_tree().get_nodes_in_group("processor"):
		if node.has_method("do_process"):
			node.do_process()
