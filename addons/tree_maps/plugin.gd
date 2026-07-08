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
	_add_tool_buttons()

	Engine.get_singleton("EditorInterface").get_selection().selection_changed.connect( _on_selection_changed )
	#get_tree().node_added.connect( _on_scene_tree_node_added )


func _exit_tree():
	_remove_tool_buttons()

	Engine.get_singleton("EditorInterface").get_selection().selection_changed.disconnect( _on_selection_changed )
	#get_tree().node_added.disconnect( _on_scene_tree_node_added )


func _on_main_screen_changed(screen_name):
	#if screen_name == "2D":
		#viewport_2d_selected = true
	#else:
		#viewport_2d_selected = false
	pass


# Unused "default" editor plugin functions.
#region
func _has_main_screen():
	return false


#func _make_visible(visible):
	#pass

#func _get_plugin_name():
	#return "Plugin"

#func _get_plugin_icon():
	#return Engine.get_singleton("EditorInterface").get_editor_theme().get_icon("Node", "EditorIcons")

#func _on_scene_tree_node_added(node):
	#if node is TreeMap: #or node is TreeMapNode:
		#pass
#endregion



## Built-in
func _handles(object: Object) -> bool:
	var selection: Array[Node] = Engine.get_singleton("EditorInterface").get_selection().get_top_selected_nodes()
	
	# Filter for only TreeMap and TreeMapNode
	if selection.filter( func(node): if node is TreeMap or node is TreeMapNode: return node ):
		if selection:
			# Clear last selected TreeMap before updating TreeMap selection.
			if selected_tree_map:
				selected_tree_map.selected_nodes.clear()
				selected_tree_map.queue_redraw()
				#print(selected_tree_map)

			# Search for first TreeMap in selection.
			for node in selection:
				if node is TreeMap or node is TreeMapNode:
						
					if node is TreeMapNode:
						selected_tree_map = node.get_parent()
						break
					elif node is TreeMap:
						selected_tree_map = node
						break
					selected_tree_map.edit_state = 0  # Reset edit state to NONE to prevent tool trigger when swapping TreeMaps

			# Update tool buttons display to match the selected TreeMap's editing state
			if selected_tree_map:
				if selected_tree_map.edit_state != TreeMap.EditStates.NONE:
					tool_buttons.get_buttons()[max(selected_tree_map.edit_state - 1, 0)].button_pressed = true
				else:
					for b in tool_buttons.get_buttons():
						b.button_pressed = false
				chain_button.button_pressed = selected_tree_map.chaining_enabled

			# Apply new selection to the first selected TreeMap and send selection signal.
			if selected_tree_map:
				#print(selected_tree_map, " - ", selection)
				selected_tree_map.selected_nodes = selection
				#selected_tree_map.selection_changed.emit()

		#if selected_tree_map:
			#selected_tree_map.selected_nodes = selection
			#selected_tree_map.selection_changed.emit()
		selected_tree_map.queue_redraw()

		return true
	else:
		return false


## Runs after _handles for both MouseUp and MouseDown when unselecting.
func _on_selection_changed():
	## The current transformable nodes selected in Editor
	var selection: Array[Node] = Engine.get_singleton("EditorInterface").get_selection().get_top_selected_nodes()

	# Shows this plugin's editor tools in the toolbar when a node type of this plugin is selected.
	var show = false
	for node in selection:
		if node is TreeMap or node is TreeMapNode:
			show = true
			break
	editor_tool_button_hbox.visible = show

	#if selection:
		## Clear last selected TreeMap before updating TreeMap selection.
		#if selected_tree_map:
			#selected_tree_map.selected_nodes.clear()
			#selected_tree_map.selection_changed.emit()
#
		## Search for first TreeMap in selection.
		#for node in selection:
			#if node is TreeMap or node is TreeMapNode:
				#if node is TreeMapNode:
					#selected_tree_map = node.get_parent()
					#break
				#elif node is TreeMap:
					#selected_tree_map = node
					#break
#
		#if selected_tree_map:
			## Update tool buttons display to match the selected TreeMap's editing state
			#if selected_tree_map.edit_state != TreeMap.EditStates.NONE:
				#tool_buttons.get_buttons()[max(selected_tree_map.edit_state - 1, 0)].button_pressed = true
			#else:
				#for b in tool_buttons.get_buttons():
					#b.button_pressed = false
			#chain_button.button_pressed = selected_tree_map.chaining_enabled
#
		#if selected_tree_map:
			## Apply new selection to the first selected TreeMap and send selection signal.
			#selected_tree_map.selected_nodes = selection
			##selected_tree_map.selection_changed.emit()
			#selected_tree_map.queue_redraw()
	
	# Mouse Left press
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if selected_tree_map:
			# Runs first to avoid false triggers from deleting selected nodes and losing selection
			#selected_tree_map.selection_changed.emit()
		
			if selection.is_empty():
				#print("empty selection")
				selected_tree_map.selected_nodes = []  
				selected_tree_map.queue_redraw()
				pass
			selected_tree_map.selection_changed.emit()
	# Mouse Left release
	else:
		pass
	


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	var intercepted = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#print("mouse left intercepted")
			pass
		
		# Intercept Right Mouse to clear editing mode and any selected nodes ONLY if currently editing.
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			#print("mouse right intercepted")

			# Deselect editing tools for current [TreeMap] on Mouse Right Click.
			if selected_tree_map.edit_state != TreeMap.EditStates.NONE:
				selected_tree_map.edit_state = TreeMap.EditStates.NONE
				selected_tree_map.edited_nodes.clear()
				tool_buttons.get_pressed_button().button_pressed = false
				Engine.get_singleton("EditorInterface").get_editor_toaster().push_toast("Editing disabled", EditorToaster.SEVERITY_INFO)
				intercepted = true
	return intercepted


#func editor_add_tool_buttons():
	#pass


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

	edit_button.icon = Engine.get_singleton("EditorInterface").get_editor_theme().get_icon("CurveEdit", "EditorIcons")
	edit_button.tooltip_text = "Edit Connections"

	add_button.icon = Engine.get_singleton("EditorInterface").get_editor_theme().get_icon("CurveCreate", "EditorIcons")
	add_button.tooltip_text = "Add Nodes"

	remove_button.icon = Engine.get_singleton("EditorInterface").get_editor_theme().get_icon("CurveDelete", "EditorIcons")
	remove_button.tooltip_text = "Remove Nodes"

	chain_button.icon = Engine.get_singleton("EditorInterface").get_editor_theme().get_icon("InsertAfter", "EditorIcons")
	chain_button.pressed.connect( func(): selected_tree_map.toggle_chaining() )
	chain_button.tooltip_text = "Chaining"

	lock_button.icon = Engine.get_singleton("EditorInterface").get_editor_theme().get_icon("Unlock", "EditorIcons")
	lock_button.pressed.connect( func(): selected_tree_map.toggle_locking() )
	lock_button.tooltip_text = "Lock"

	reset_button.icon = Engine.get_singleton("EditorInterface").get_editor_theme().get_icon("RotateLeft", "EditorIcons")
	reset_button.tooltip_text = "Reset (WIP)"

	info_button.icon = Engine.get_singleton("EditorInterface").get_editor_theme().get_icon("Info", "EditorIcons")
	info_button.tooltip_text = "Info (WIP)"


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


## Adds tool buttons to toolbar.
func _add_tool_buttons():
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, editor_tool_button_hbox)


## Removes tool buttons from toolbar.
func _remove_tool_buttons():
	remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, editor_tool_button_hbox)


## Adds custom nodes to the Nodes List
func _init_custom_types():
	add_custom_type("TreeMap", "Node2D",\
		preload("res://addons/tree_maps/nodes/tree_map.gd"),\
		preload("res://addons/tree_maps/nodes/TreeMap.svg"))
		#Engine.get_singleton("EditorInterface").get_editor_theme().get_icon("GraphEdit", "EditorIcons"))
	add_custom_type("TreeMapNode", "Node2D",\
		preload("res://addons/tree_maps/nodes/tree_map_node.gd"),\
		preload("res://addons/tree_maps/nodes/TreeMapNode.svg"))
		#Engine.get_singleton("EditorInterface").get_editor_theme().get_icon("GraphElement", "EditorIcons"))
