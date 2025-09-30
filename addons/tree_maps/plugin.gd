@tool
extends EditorPlugin


var tool_buttons = ButtonGroup.new()

var editor_tool_button = preload("res://addons/tree_maps/buttons/editor_tool_button.tscn")
var editor_tool_button_hbox = HBoxContainer.new()

var edit_button: Button = editor_tool_button.instantiate()
var add_button: Button = editor_tool_button.instantiate()
var remove_button: Button = editor_tool_button.instantiate()
var chain_button: Button = editor_tool_button.instantiate()
var lock_button: Button = Button.new()
var reset_button: Button = Button.new()
var info_button: Button = Button.new()
#var tools = {
	#add = editor_tool_button.instantiate(),
	#remove = editor_tool_button.instantiate(),
#}

var selected_tree_map: TreeMap


func _init() -> void:
	tool_buttons.allow_unpress = true
	tool_buttons.pressed.connect(_on_tool_button_pressed)
	_init_tool_buttons()
	_init_custom_types()
	#main_screen_changed.connect(_on_main_screen_changed)


func _enter_tree():
	#add_autoload_singleton("PluginState", "res://addons/tree_maps/plugin_state.gd")
	_add_tool_buttons()

	EditorInterface.get_selection().selection_changed.connect( _on_selection_changed )
	#get_tree().node_added.connect( _on_scene_tree_node_added )


func _exit_tree():
	#remove_autoload_singleton("PluginState")
	_remove_tool_buttons()

	EditorInterface.get_selection().selection_changed.disconnect( _on_selection_changed )
	#get_tree().node_added.disconnect( _on_scene_tree_node_added )


func _on_main_screen_changed(screen_name):
	#if screen_name == "2D":
		#viewport_2d_selected = true
	#else:
		#viewport_2d_selected = false
	pass


func _has_main_screen():
	return false

#func _make_visible(visible):
	#pass

#func _get_plugin_name():
	#return "Plugin"

#func _get_plugin_icon():
	#return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")


#func _on_scene_tree_node_added(node):
	#if node is TreeMap: #or node is TreeMapNode:
		#pass


func _on_selection_changed():
	var selection = EditorInterface.get_selection().get_transformable_selected_nodes()
	var show = false
	for node in selection:
		if node is TreeMap or node is TreeMapNode:
			show = true
			break
	editor_tool_button_hbox.visible = show


func _handles(object: Object) -> bool:
	if object is TreeMap or object is TreeMapNode:
		if object is TreeMapNode:
			selected_tree_map = object.get_parent()
		if object is TreeMap:
			selected_tree_map = object
		# Update tool buttons display to match the selected TreeMap's editing state
		if selected_tree_map.edit_state != TreeMap.EditStates.NONE:
			tool_buttons.get_buttons()[max(selected_tree_map.edit_state - 1, 0)].button_pressed = true
		else:
			for b in tool_buttons.get_buttons():
				b.button_pressed = false
		chain_button.button_pressed = selected_tree_map.chaining_enabled
		return true
	else: return false


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	var intercepted = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#print("mouse left intercepted")
			pass
		if event.button_index == MOUSE_BUTTON_RIGHT:
			# Disable editing on the selected [TreeMap] on Mouse Right Click
			if selected_tree_map.edit_state != TreeMap.EditStates.NONE:
				selected_tree_map.edit_state = TreeMap.EditStates.NONE
				selected_tree_map.edited_nodes.clear()
				tool_buttons.get_pressed_button().button_pressed = false
				EditorInterface.get_editor_toaster().push_toast("Editing disabled", EditorToaster.SEVERITY_INFO)
				intercepted = true
			#print("mouse right intercepted")
	return intercepted


func editor_add_tool_buttons():
	pass


func _init_tool_buttons():
	editor_tool_button_hbox.visible = false
	editor_tool_button_hbox.add_child(edit_button)
	editor_tool_button_hbox.add_child(add_button)
	editor_tool_button_hbox.add_child(remove_button)
	editor_tool_button_hbox.add_child(VSeparator.new())
	editor_tool_button_hbox.add_child(chain_button)
	editor_tool_button_hbox.add_child(lock_button)
	editor_tool_button_hbox.add_child(VSeparator.new())
	editor_tool_button_hbox.add_child(reset_button)
	editor_tool_button_hbox.add_child(info_button)

	edit_button.button_group = tool_buttons
	add_button.button_group = tool_buttons
	remove_button.button_group = tool_buttons

	for b in editor_tool_button_hbox.get_children():
		b.size.x = b.size.y  # Make buttons square

	edit_button.icon = EditorInterface.get_editor_theme().get_icon("CurveEdit", "EditorIcons")
	edit_button.tooltip_text = "Edit Connections"

	add_button.icon = EditorInterface.get_editor_theme().get_icon("CurveCreate", "EditorIcons")
	add_button.tooltip_text = "Add Nodes"

	remove_button.icon = EditorInterface.get_editor_theme().get_icon("CurveDelete", "EditorIcons")
	remove_button.tooltip_text = "Remove Nodes"

	chain_button.icon = EditorInterface.get_editor_theme().get_icon("InsertAfter", "EditorIcons")
	chain_button.pressed.connect( func(): selected_tree_map.toggle_chaining() )
	chain_button.tooltip_text = "Chaining"

	lock_button.icon = EditorInterface.get_editor_theme().get_icon("Unlock", "EditorIcons")
	#chain_button.pressed.connect( func(): selected_tree_map.toggle_chaining() )
	lock_button.tooltip_text = "Lock"

	reset_button.icon = EditorInterface.get_editor_theme().get_icon("RotateLeft", "EditorIcons")
	reset_button.tooltip_text = "Reset"

	info_button.icon = EditorInterface.get_editor_theme().get_icon("Info", "EditorIcons")
	info_button.tooltip_text = "info"


func _on_tool_button_pressed(button):
	match button:
		edit_button:
			selected_tree_map.toggle_editing(button.button_pressed)
		add_button:
			selected_tree_map.toggle_adding(button.button_pressed)
		remove_button:
			selected_tree_map.toggle_removing(button.button_pressed)

	if tool_buttons.get_pressed_button() == null:
		selected_tree_map.edit_state = TreeMap.EditStates.NONE


func _add_tool_buttons():
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, editor_tool_button_hbox)


func _remove_tool_buttons():
	remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, editor_tool_button_hbox)


func _init_custom_types():
	add_custom_type("TreeMap", "Node2D",\
		preload("res://addons/tree_maps/nodes/tree_map.gd"),\
		preload("res://addons/tree_maps/nodes/TreeMap.svg"))
		#EditorInterface.get_editor_theme().get_icon("GraphEdit", "EditorIcons"))
	add_custom_type("TreeMapNode", "Node2D",\
		preload("res://addons/tree_maps/nodes/tree_map_node.gd"),\
		preload("res://addons/tree_maps/nodes/TreeMapNode.svg"))
		#EditorInterface.get_editor_theme().get_icon("GraphElement", "EditorIcons"))
