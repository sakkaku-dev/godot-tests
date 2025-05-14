class_name ButtonPart
extends TextureRect

@export var normal_tex: Texture2D
@export var hover_tex: Texture2D

func normal():
	texture = normal_tex

func hover():
	texture = hover_tex
