extends Control
class_name Textbox


signal finish_dialog()


var text_array: Array
var text_idx: int
var finished_printing := false


onready var text_label: RichTextLabel = $Textbox/TextLabel
onready var arrow: AnimatedSprite = $Textbox/Arrow


func _ready() -> void:
	self.visible = false
	arrow.visible = false
	text_label.visible_characters = 1
	set_physics_process(false)


func _on_display_text(
	text: Array
) -> void:
	text_array = text
	text_idx = 0
	
	self.visible = true
	set_physics_process(true)
	text_label.text = text_array[0]


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if finished_printing:
			arrow.visible = false
			text_label.visible_characters = 1
			finished_printing = false
			text_idx += 1
			if text_idx < text_array.size():
				text_label.text = text_array[text_idx]
			else:
				self.visible = false
				set_physics_process(false)
				emit_signal("finish_dialog")
		else:
			text_label.visible_characters = -1
			finish_printing()
	
	if not finished_printing:
		text_label.visible_characters += 1
		if text_label.visible_characters == text_label.text.length():
			finish_printing()


func finish_printing() -> void:
	arrow.visible = true
	finished_printing = true
