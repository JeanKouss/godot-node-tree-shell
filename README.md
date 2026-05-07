<h1 align="center">Godot Tree Shell</h1>

<p align="center">
  An in-game shell terminal for inspecting and manipulating the scene tree at runtime.<br/>
  Navigate nodes, read/write properties, call methods — all from a terminal overlay.
</p>

<p align="center">
  <img alt="Godot v4.x" src="https://img.shields.io/badge/Godot-4.x-%23478cbf?logo=godot-engine&logoColor=white" />
  <img alt="License MIT" src="https://img.shields.io/badge/license-MIT-green" />
  <img alt="Version" src="https://img.shields.io/badge/version-0.1.0-blue" />
</p>

---

## ✨ Features

- **Navigate the scene tree** — traverse nodes using familiar shell-like commands
- **Inspect & modify properties** — get and set any property on the current node
- **Call methods** — invoke functions on nodes with arguments
- **Autocomplete** — tab-completion for node properties and methods
- **Command history** — navigate previous commands with the arrow keys
- **Tree view** — visualize the subtree from any node

**Coming soon:**
- **Signal emission** — trigger signals on any node directly from the shell
- **Property watching** — monitor a property in real time and get notified whenever its value changes
- **Property value helpers** — context-aware input UI based on property type (e.g. a color picker when editing a `Color` property)

---

## 💾 Installation

### Asset Library _(Recommended)_

1. In Godot, open the **AssetLib** tab.
2. Search for **"Godot Tree Shell"** and install it.
3. Enable the plugin under **Project → Project Settings → Plugins**.

### Manual

1. Download or clone this repository.
2. Copy the `addons/godot-tree-shell` folder into your project's `addons/` directory.
3. Enable the plugin under **Project → Project Settings → Plugins**.

The `TreeShellCore` autoload singleton is registered automatically when the plugin is enabled.

> [!NOTE]
> For more help, see [Godot's official documentation on installing plugins](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).

---

## 🚀 Usage

Once the plugin is enabled, press `F4` at runtime to toggle the terminal overlay. No extra setup needed.

At runtime, the prompt shows the active node path:

```
[/root]$ <command>
```

> [!NOTE]
> The terminal opens as a sub-window. If **embed subwindows** is enabled in your project settings, a warning banner will appear — you can dismiss it or toggle the setting directly from the banner.

### Commands

| Command | Arguments | Description |
|---|---|---|
| `help` | — | List all available commands |
| `lc` | — | List children of the current node |
| `cn` | `[path]` | Change current node, or print current node if no path is given |
| `get` | `<property>` | Get the value of a property on the current node |
| `set` | `<property> <value>` | Set a property on the current node |
| `call` | `<function_name> [args...]` | Call a method on the current node |
| `tree` | `[depth]` | Show the subtree from the current node |
| `history` | `[n]` | Show command history (optionally last `n` entries) |

### Keyboard Shortcuts

| Key | Action |
|---|---|
| `F4` | Toggle the terminal overlay |
| `Enter` | Execute command / confirm autocomplete |
| `↑` / `↓` | Navigate history or autocomplete candidates |
| `Escape` | Close the autocomplete panel |

---

