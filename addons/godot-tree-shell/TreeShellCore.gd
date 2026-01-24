extends Node

signal command_execution_requested(command: String, on: Node)

signal current_node_changed(new_node: Node)

## show_as can be "text", "list", "tree", "mute"
signal command_execution_finished(result: Variant, show_as: String)


@onready var current_node: Node = _get_default_current_node():
    set(val):
        current_node = val
        emit_signal("current_node_changed", val)
        _cache_current_node_properties()
        _cache_current_node_functions()
    get():
        if not current_node:
            return _get_default_current_node()
        return current_node

var current_node_properties: Dictionary = {}
var current_node_functions: Dictionary = {}

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
    },
    "get": {
        "name": "Get property value",
        "description": "Get the value of a property of the current node",
        "function": get_property_value,
        "parameters": ["property"],
    },
    "set": {
        "name": "Set property",
        "description": "Set a property of the current node",
        "function": set_property_value,
        "parameters": ["property", "value"],
    },
    "call": {
        "name": "Call function",
        "description": "Call a function of the current node",
        "function": call_node_method,
        "parameters": ["function_name", "..."],
    },
}

func execute_command(command: String) -> void:
    if command.is_empty():
        command_execution_finished.emit("Command is empty", "mute")
        return
    command_execution_requested.emit(command, current_node)
    var parsed_command = _parse_command(command)
    var cmd_dict: Dictionary = command_registry.get(parsed_command[0], {})
    if cmd_dict.is_empty():
        command_execution_finished.emit("Command not found", "text")
        return
    var cmd_function: Callable = cmd_dict['function']
    var cmd_params: Array = parsed_command.slice(1)
    if cmd_params.size() != cmd_dict['parameters'].size():
        command_execution_finished.emit("Invalid parameters", "text")
        return
    print(cmd_function)
    print(cmd_params)
    cmd_function.callv(cmd_params)


func autocomplete(input: String, autocomplete_index: int = 0) -> String:
    var parsed_cmd = _parse_command(input)
    if parsed_cmd.size() == 0:
        return input
    var cmd_name = parsed_cmd[0]
    match cmd_name:
        "cn":
            return input
        "get":
            if parsed_cmd.size() > 2:
                return input
            if parsed_cmd.size() == 1 and input[-1] != " ":
                return input
            var prop_start = parsed_cmd[1] if parsed_cmd.size() == 2 else ""
            # get a property that start with prop_start at the autocomplete_index modulo the number of possible properties
            var possible_properties = []
            for property_name in current_node_properties.keys():
                if property_name.begins_with(prop_start):
                    possible_properties.append(property_name)
            var index = autocomplete_index % possible_properties.size()
            return "get " + possible_properties[index]
        "set":
            if parsed_cmd.size() > 2:
                return input
            if parsed_cmd.size() == 1 and input[-1] != " ":
                return input
            var prop_start = parsed_cmd[1] if parsed_cmd.size() == 2 else ""
            # get a property that start with prop_start at the autocomplete_index modulo the number of possible properties
            var possible_properties = []
            for property_name in current_node_properties.keys():
                if property_name.begins_with(prop_start):
                    possible_properties.append(property_name)
            var index = autocomplete_index % possible_properties.size()
            return "set " + possible_properties[index]
        _:
            return input

#region Helpers

func _get_default_current_node() -> Node:
    return get_tree().get_root()

func _cache_current_node_properties() -> void:
    current_node_properties.clear()
    for property in current_node.get_property_list():
        current_node_properties[property.name] = {
            'type': property.type,
            'class_name': property.class_name
        }

func _cache_current_node_functions() -> void:
    current_node_functions.clear()
    for function in current_node.get_method_list():
        current_node_functions[function.name] = {
            'args': function.args,
        }

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
    var new_node = current_node.get_node_or_null(path)
    if new_node:
        current_node = new_node
        command_execution_finished.emit("Node changed", "mute")
    else:
        command_execution_finished.emit("Node not found", "text")

func get_property_value(property: String) -> void:
    if not current_node_properties.has(property):
        command_execution_finished.emit("Property not available on current node", "text")
        return
    var value = current_node.get(property)
    command_execution_finished.emit(value, "text")

func set_property_value(property: String, str_value: String) -> void:
    var expression = Expression.new()
    var error = expression.parse(str_value)
    if error:
        command_execution_finished.emit("Unable to parse value", "text")
        return
    var value = expression.execute()
    if expression.has_execute_failed():
        command_execution_finished.emit("Unable to parse value", "text")
        return
    if not current_node_properties.has(property):
        command_execution_finished.emit("Property not available on current node", "text")
        return
    var current_value = current_node.get(property)
    if typeof(value) != typeof(current_value):
        command_execution_finished.emit("Value type does not match property type", "text")
        return
    current_node.set(property, value)
    command_execution_finished.emit("Property set", "mute")

func call_node_method(function_name: String, ...args: Array) -> void:
    if not current_node_functions.has(function_name):
        command_execution_finished.emit("Function not available on current node", "text")
        return
    # evaluate every args
    for i in range(args.size()):
        var expression = Expression.new()
        var error = expression.parse(args[i])
        if error:
            command_execution_finished.emit("Unable to parse value", "text")
            return
        var value = expression.execute()
        if expression.has_execute_failed():
            command_execution_finished.emit("Unable to parse value", "text")
            return
        args[i] = value
    var result = current_node.callv(function_name, args)
    command_execution_finished.emit(result, "text")

#endregion
