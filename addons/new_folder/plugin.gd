@tool
extends EditorPlugin


var editor_tool_button = preload("res://addons/new_folder/buttons/editor_tool_button.tscn")
var editor_tool_button_hbox = HBoxContainer.new()

var edit_button: Button = editor_tool_button.instantiate()
var add_button: Button = editor_tool_button.instantiate()
var remove_button: Button = editor_tool_button.instantiate()
var chain_button: Button = editor_tool_button.instantiate()

var tools = {
	add = editor_tool_button.instantiate(),
	remove = editor_tool_button.instantiate(),
	#collapse = editor_tool_button.instantiate(),
	#merge = editor_tool_button.instantiate()
}


func _init() -> void:
	_init_tool_buttons()


func _enter_tree():
	_add_tool_buttons()

	EditorInterface.get_selection().selection_changed.connect( _on_selection_changed )
	get_tree().node_added.connect( _on_scene_tree_node_added )


func _exit_tree():
	_remove_tool_buttons()

	EditorInterface.get_selection().selection_changed.disconnect( _on_selection_changed )
	get_tree().node_added.disconnect( _on_scene_tree_node_added )


func _has_main_screen():
	return false

#func _make_visible(visible):
	#pass

#func _get_plugin_name():
	#return "Plugin"

#func _get_plugin_icon():
	#return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")


func _on_scene_tree_node_added(node):
	if node is TreeMap: #or node is TreeMapNode:
		pass


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
			PluginState.selected_tree_map = object.get_parent()
		if object is TreeMap:
			PluginState.selected_tree_map = object
		edit_button.button_pressed = PluginState.selected_tree_map.editing # Update edit_button to match editing state
		return true
	else: return false


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#if selected_node is TreeMap:

			#for node_pos in selected_node.nodes:
				#var mouse_dist = get_viewport().get_mouse_position().distance_to(node_pos)
				#print(mouse_dist)
				#if mouse_dist <= 100:
					#print("KAJSDNAJS")
			#print("mouse left intercepted")
			return false
		else:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				# Disable editing on the selected [TreeMap] on Mouse Right Click
				if PluginState.selected_tree_map.editing:
					PluginState.selected_tree_map.editing = false
					edit_button.button_pressed = false
					EditorInterface.get_editor_toaster().push_toast("Editing disabled", EditorToaster.SEVERITY_INFO)
					return true
				#print("mouse right intercepted")
			return false
	else:  return false


func _init_tool_buttons():
	editor_tool_button_hbox.visible = false
	editor_tool_button_hbox.add_child(edit_button)
	editor_tool_button_hbox.add_child(add_button)
	editor_tool_button_hbox.add_child(remove_button)
	editor_tool_button_hbox.add_child(VSeparator.new())

	for b in editor_tool_button_hbox.get_children():
		#b.visible = false  # hide buttons by default
		b.size.x = b.size.y  # Make buttons square

	#edit_button.icon = EditorInterface.get_editor_theme().get_icon("EditAddRemove", "EditorIcons")
	edit_button.icon = EditorInterface.get_editor_theme().get_icon("CurveEdit", "EditorIcons")
	edit_button.pressed.connect( func(): PluginState.selected_tree_map.toggle_editing() )
	edit_button.tooltip_text = "Edit Connections"

	add_button.icon = EditorInterface.get_editor_theme().get_icon("CurveCreate", "EditorIcons")
	#add_button.pressed.connect( func(): pass )
	add_button.tooltip_text = "Add Nodes"

	remove_button.icon = EditorInterface.get_editor_theme().get_icon("CurveDelete", "EditorIcons")
	#remove_button.pressed.connect( func(): pass )
	remove_button.tooltip_text = "Remove Nodes"



func _add_tool_buttons():
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, editor_tool_button_hbox)
	#add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, edit_button)
	#add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, add_button)
	#add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, remove_button)


func _remove_tool_buttons():
	remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, editor_tool_button_hbox)
	#remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, edit_button)
	#remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, add_button)
	#remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, remove_button)
