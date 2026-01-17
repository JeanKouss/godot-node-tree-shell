extends Node


signal command_execution_requested(command: String, on: Node)

signal current_node_changed(new_node: Node)

## show_as can be "text", "list", "tree"
signal command_execution_finished(result: Variant, show_as: String)


@onready var current_node: Node = get_tree().get_root():
    set(val):
        current_node = val
        emit_signal("current_node_changed", val)


var command_registry: Dictionary = {
    "lc": {
        "name": "List children",
        "description": "List the children of the current node",
        "function": list_children,
        "parameters": [],
    },
    "cn": {
        "name": "Change node",
        "description": "Change the current node",
        "function": change_node,
        "parameters": ["path"],
    }
}

func execute_command(command: String) -> void:
    command_execution_requested.emit(command, current_node)
    var parsed_command = _parse_command(command)
    var cmd_dict: Dictionary = command_registry.get(parsed_command[0], {})
    if cmd_dict.is_empty():
        command_execution_finished.emit("Command not found", "text")
        return
    var cmd_function: Callable = cmd_dict['function']
    var cmd_params: Array = parsed_command.slice(1)
    cmd_function.callv(cmd_params)
    

#region Helpers

func _parse_command(command: String):
    # Split command into expressions separated by spaces that are not in quotes
    var regex = RegEx.new()
    regex.compile('"[^"]*"|\'[^\']*\'|\\S+')
    var result = []
    for m in regex.search_all(command):
        result.append(m.get_string())
    return result

#endregion


#region Commands

func list_children() -> void:
    var children_names = []
    for child in current_node.get_children():
        children_names.append(child.name)
    command_execution_finished.emit(children_names, "list")

func change_node(path: String) -> void:
    var new_node = current_node.get_node(path)
    print(path)
    if new_node:
        current_node = new_node
    else:
        command_execution_finished.emit("Node not found", "text")

#endregion