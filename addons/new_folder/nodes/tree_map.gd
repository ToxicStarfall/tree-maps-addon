@tool
class_name TreeMap
extends Node2D

signal notify_cleanup(node)

enum EditStates { NONE, EDITING, ADDING, REMOVING }

@export var edit_state: EditStates = EditStates.NONE
@export var chaining_enabled: bool = false

@export var selected_nodes: Array = []
@export var edited_nodes: Array[TreeMapNode] = []

@export var nodes: Array[Vector2] = []


@export_category("Customization")
#@export var node_instance: PackedScene
#@export var min_length: int = 0
#@export var max_length: int = 0

@export_group("Overrides")
const default_color = Color.WHITE
#@export_subgroup("Transform")

@export_subgroup("Nodes")
@export var node_color: Color = default_color
#@export var node_texture: Color

@export_subgroup("Lines")
@export var line_color: Color = default_color
#@export var line_border_color: Color
#@export var line_texture: Texture2D
#@export var line_fill_texture: Texture2D

@export_subgroup("Arrows")
@export var arrow_color: Color = default_color
#@export var arrow_border_color: Color
#@export var arrow_texture: Texture2D


func _setup():
	nodes.clear()
	for child in get_children():
		if child is TreeMapNode:
			nodes.append(child.position)
			setup_tree_map_node(child)


## Apply inherited properties to children TreeMapNodes
func setup_tree_map_node(node):
	# Before updating inherited properties, check if that property was actually inherited.
	if node.line_color == node.parent_line_color:
		node.parent_line_color = line_color
		node.line_color = node.property_get_revert("line_color") # set to parent_line_color
	else:
		node.parent_line_color = line_color
	#node.line_color = node.property_get_revert("line_color")
	node.apply_properties()


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		#set_notify_transform(true)
		set_physics_process(true)
		EditorInterface.get_inspector().property_edited.connect( _on_property_edited )
		EditorInterface.get_selection().selection_changed.connect( _on_selection_changed )
		child_entered_tree.connect( _on_child_entered_tree )
		child_exiting_tree.connect( _on_child_exiting_tree )
	_setup()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		EditorInterface.get_inspector().property_edited.disconnect( _on_property_edited )
		EditorInterface.get_selection().selection_changed.disconnect( _on_selection_changed )
		child_entered_tree.disconnect( _on_child_entered_tree )
		child_exiting_tree.disconnect( _on_child_exiting_tree )
		nodes.clear()


## https://forum.godotengine.org/t/in-godot-how-can-i-listen-for-changes-in-the-properties-of-nodes-within-the-editor-additionally-how-can-this-be-used-in-a-plugin/35330/4
#func _notification(what):
	#if what == NOTIFICATION_TRANSFORM_CHANGED:
		#pass


func _on_child_entered_tree(child: Node) -> void:
	if child is TreeMapNode:
		child.moved.connect( _on_node_moved )
		#child.connections_edited.connect( _on_node_connections_edited )
		# Adjust saved indexes for child items' connections


func _on_child_exiting_tree(child: Node) -> void:
	if child is TreeMapNode:
		#notify_cleanup.emit()
		child.moved.disconnect( _on_node_moved )
		#child.connections_edited.disconnect( _on_node_connections_edited )
		# Adjust saved indexes for child items' connections


func _physics_process(delta: float) -> void:
	#if viewport_2d_selected:
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			#print("ASKDM")
			pass


# Refresh properties on children
func _on_property_edited(property) -> void:
	if EditorInterface.get_inspector().get_edited_object() == self:
		match property:
			# Update childrens' properties
			"line_color": #"node_color", ""
				for i in get_children():
					if i is TreeMapNode:
						setup_tree_map_node(i)
						i.apply_properties()


func _on_selection_changed() -> void:
	selected_nodes = EditorInterface.get_selection().get_transformable_selected_nodes()
	var tree_map_nodes = get_tree_map_nodes_from(selected_nodes)

	match edit_state:
		EditStates.EDITING:
			# [Check for nodes to connect FROM] and [Check for nodes to connect TO]
			if edited_nodes.size() >= 1 and tree_map_nodes.size() >= 1:
				for node in edited_nodes:
					var target: TreeMapNode = tree_map_nodes[0]
					# If [Node] does not have [Target] as a output (not connected).
					if not node.has_connection(target.get_index(), node.outputs):
						# If [Target] does not have [Node] as a output
						if not target.outputs.has(node.get_index()):
							if not node == target:
								connnect_nodes([node], target)
						else: # Else, replace exusting connection
							node.swap_connection(target.get_index(), node.inputs, node.outputs)
							target.swap_connection(node.get_index(), target.outputs, target.inputs)
							node.queue_redraw()  # Refresh the origin node
							target.queue_redraw()
					else: # Else, remove existing connection
						disconnect_nodes([node], target)
					select_node(node)
		EditStates.ADDING:
			if tree_map_nodes.is_empty():
				var new_node = create_tree_map_node()
				setup_tree_map_node(new_node)
				select_node(new_node)
				if chaining_enabled:
					#connnect_nodes([node], target)
					pass
		EditStates.REMOVING:
			if !tree_map_nodes.is_empty():
				var target: TreeMapNode = tree_map_nodes[0]
				select_node(target.get_parent())   # Reselect parent TreeMap to make removing nodes clean.
				remove_tree_map_node(target).queue_free()


func _on_node_moved(node):
	#print(node)
	node.queue_redraw()
	for i in node.inputs:
		node = get_input_output_node(i)
		if node: node.queue_redraw()
	nodes[node.get_index()] = node.position
	queue_redraw()


func toggle_editing(state: bool):
	if state == true:
		# Add TreeMapNodes to editing selection
		for i in EditorInterface.get_selection().get_transformable_selected_nodes():
			if i is TreeMapNode: self.edited_nodes.append(i)
		edit_state = TreeMap.EditStates.EDITING
		EditorInterface.get_editor_toaster().push_toast("Editing enabled", EditorToaster.SEVERITY_INFO)
	else:
		edited_nodes.clear()
		EditorInterface.get_editor_toaster().push_toast("Editing disabled", EditorToaster.SEVERITY_INFO)


func toggle_adding(state: bool):
	if state == true:
		edit_state = TreeMap.EditStates.ADDING
	else:
		EditorInterface.get_editor_toaster().push_toast("Adding disabled", EditorToaster.SEVERITY_INFO)


func toggle_removing(state: bool):
	if state == true:
		edit_state = TreeMap.EditStates.REMOVING
		select_node(self)  # Select parent TreeMap to make removing nodes clean.
	else:
		EditorInterface.get_editor_toaster().push_toast("Removing disabled", EditorToaster.SEVERITY_INFO)


func toggle_chaining():
	chaining_enabled = !chaining_enabled
	if chaining_enabled:
		EditorInterface.get_editor_toaster().push_toast("Chaining enabled", EditorToaster.SEVERITY_INFO)
	else:
		EditorInterface.get_editor_toaster().push_toast("Chaining disabled", EditorToaster.SEVERITY_INFO)


func create_tree_map_node() -> TreeMapNode:
	var tree_map_node = TreeMapNode.new()
	add_child(tree_map_node)
	tree_map_node.global_position = get_global_mouse_position()
	tree_map_node.owner = EditorInterface.get_edited_scene_root()
	tree_map_node.name = tree_map_node.get_script().get_global_name()
	nodes.append(tree_map_node.position)
	return tree_map_node


func remove_tree_map_node(node) -> TreeMapNode:
	var idx = node.get_index()
	nodes.erase(node.position)
	for i in node.inputs: # Remove idx from output connection lists
		get_child(i).outputs.erase(idx)
		get_child(i).queue_redraw()
	for i in node.outputs: # Remove idx from input connection lists
		get_child(i).inputs.erase(idx)
		get_child(i).queue_redraw()
	remove_child(node)
	return node


func connnect_nodes(connecting_nodes: Array[TreeMapNode], target_node: TreeMapNode):
	for connecting_node in connecting_nodes:
		connecting_node.add_connection(target_node.get_index(), connecting_node.outputs)
		target_node.add_connection(connecting_node.get_index(), target_node.inputs)


func disconnect_nodes(connecting_nodes: Array[TreeMapNode], target_node: TreeMapNode):
	for connecting_node in connecting_nodes:
		connecting_node.remove_connection(target_node.get_index(), connecting_node.outputs)
		target_node.remove_connection(connecting_node.get_index(), target_node.inputs)


func select_node(node):
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(node)


func select_nodes(nodes: Array):
	EditorInterface.get_selection().clear()
	for node in nodes:
		EditorInterface.get_selection().add_node(node)


#func swap_node_connection(idx, old_array, new_array):
	#old_array.erase(idx)
	#new_array.append(idx)

func get_tree_map_nodes_from(array: Array[Node]) -> Array[TreeMapNode]:
	var tree_map_nodes: Array[TreeMapNode] = []
	for node in array:
		if node is TreeMapNode:
			tree_map_nodes.append(node)
	return tree_map_nodes


func get_last_selected_node() -> TreeMapNode:
	var last_selection
	var selected_nodes = EditorInterface.get_selection().get_transformable_selected_nodes()
	for i in selected_nodes.size():
		last_selection = selected_nodes[-i-1]
		if last_selection is TreeMapNode:
			break
	return last_selection


func get_input_output_node(idx):
	if self.get_child_count() >= idx + 1:
		return self.get_child(idx)
