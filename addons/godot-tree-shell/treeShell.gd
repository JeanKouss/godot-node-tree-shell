@tool
extends EditorPlugin


const tree_shell_core_path = "res://addons/godot-tree-shell/TreeShellCore.gd"


func _enable_plugin() -> void:
    add_autoload_singleton("TreeShellCore", tree_shell_core_path)


func _disable_plugin() -> void:
    remove_autoload_singleton("TreeShellCore")


func _enter_tree() -> void:
    # Initialization of the plugin goes here.
    pass


func _exit_tree() -> void:
    # Clean-up of the plugin goes here.
    pass
