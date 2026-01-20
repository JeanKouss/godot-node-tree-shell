extends Window


@onready var shell_history = %ShellHistory

func _ready() -> void:
    TreeShellCore.command_execution_requested.connect(_on_command_execution_requested)
    TreeShellCore.command_execution_finished.connect(_on_command_execution_finished)


func _on_command_execution_requested(command: String, on: Node) -> void:
    _append_command(command, on)
    

func _append_command(text: String, on: Node) -> void:
    var cmd_label = Label.new()
    cmd_label.text = "[%s]$ %s" % [on.get_path(), text]
    shell_history.add_child(cmd_label)
    shell_history.move_child(cmd_label, -3) # Move to the second last position

func _on_command_execution_finished(result: Variant, show_as: String) -> void:
    match show_as:
        "text":
            var result_label = Label.new()
            result_label.text = str(result)
            shell_history.add_child(result_label)
            shell_history.move_child(result_label, -3) # Move to the second last position
        "list":
            var list_container = VBoxContainer.new()
            for item in result:
                var item_label = Label.new()
                item_label.text = str(item)
                list_container.add_child(item_label)
            shell_history.add_child(list_container)
            shell_history.move_child(list_container, -3)
        "tree":
            pass
        "mute":
            pass # Do not show anything
