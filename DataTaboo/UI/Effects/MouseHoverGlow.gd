extends TextureRect


func _ready():
	self_modulate.a = 0


func _on_TextureRect_mouse_entered():
	self_modulate.a = 0.50

func _on_TextureRect_mouse_exited():
	self_modulate.a = 0
