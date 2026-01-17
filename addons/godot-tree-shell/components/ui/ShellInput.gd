extends HBoxContainer

@onready var line_edit = $LineEdit

func _ready() -> void:
    TreeShellCore.current_node_changed.connect(_on_current_node_changed)
    TreeShellCore.command_execution_finished.connect(_on_command_execution_finished)
    _update_current_node_path(TreeShellCore.current_node)
    

func _on_current_node_changed(new_node: Node) -> void:
    _update_current_node_path(new_node)

func _on_command_execution_finished(result: Variant, show_as: String) -> void:
    show()
    line_edit.call_deferred("grab_focus")


func _unhandled_key_input(event: InputEvent) -> void:
    if event.keycode == KEY_ENTER:
        var command = clean_input_text(line_edit.text)
        line_edit.clear()
        line_edit.call_deferred("release_focus")
        hide()
        TreeShellCore.execute_command(command)
    # line_edit.call_deferred("grab_focus")

func _update_current_node_path(node: Node) -> void:
    %CurrentNodePath.text = node.get_path()


func clean_input_text(input: String) -> String:
    input = input.strip_edges()
    return input