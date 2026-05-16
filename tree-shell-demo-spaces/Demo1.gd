extends Node2D

signal request_color_change(new_color: Color)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    request_color_change.connect(_on_color_change_requested)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_color_change_requested(new_color: Color) -> void:
    modulate = new_color
