extends HBoxContainer

@onready var line_edit = $LineEdit

var autocomplete_index = 0
var autocomplete_input = ""

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
        if command:
            line_edit.clear()
            line_edit.call_deferred("release_focus")
            hide()
            TreeShellCore.execute_command(command)
    if event.keycode == KEY_TAB and not event.is_pressed():
        print(autocomplete_index)
        print(autocomplete_input)
        if autocomplete_index == 0:
            autocomplete_input = line_edit.text
        var autocomplete = TreeShellCore.autocomplete(autocomplete_input, autocomplete_index)
        line_edit.text = autocomplete
        line_edit.caret_column = autocomplete.length()
        autocomplete_index += 1
    else:
        autocomplete_index = 0


func _update_current_node_path(node: Node) -> void:
    %CurrentNodePath.text = node.get_path()


func clean_input_text(input: String) -> String:
    input = input.strip_edges()
    return input
