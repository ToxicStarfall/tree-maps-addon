@tool
class_name TreeMap
extends Node2D

signal notify_cleanup(node)


@export var editing: bool = false
#@export var adding: bool = false
#@export var removing: bool = false

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


func setup_tree_map_node(node):
	node.default_line_color = line_color
	node.default_arrow_color = arrow_color
	#node.line_color = line_color
	#node.arrow_color = arrow_color


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)
		#EditorInterface.get_inspector().property_edited.connect( _on_property_edited )
		EditorInterface.get_selection().selection_changed.connect( _on_selection_changed )
		child_entered_tree.connect( _on_child_entered_tree )
		child_exiting_tree.connect( _on_child_exiting_tree )
		_setup()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		#EditorInterface.get_inspector().property_edited.disconnect( _on_property_edited )
		EditorInterface.get_selection().selection_changed.disconnect( _on_selection_changed )
		child_entered_tree.disconnect( _on_child_entered_tree )
		child_exiting_tree.disconnect( _on_child_exiting_tree )
		nodes.clear()


## https://forum.godotengine.org/t/in-godot-how-can-i-listen-for-changes-in-the-properties-of-nodes-within-the-editor-additionally-how-can-this-be-used-in-a-plugin/35330/4
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		pass


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


#func _on_property_edited() -> void:
	# Refresh properties on children
	#pass


func _on_selection_changed() -> void:
	selected_nodes = EditorInterface.get_selection().get_transformable_selected_nodes()

	if editing:
		var tree_map_nodes = get_tree_map_nodes_from(selected_nodes)
		# [Check for nodes to connect FROM] and [Check for nodes to connect TO]
		if edited_nodes.size() >= 1 and tree_map_nodes.size() >= 1:
			for node in edited_nodes:
				var target: TreeMapNode = tree_map_nodes[0]
				# If [Node] does not have [Target] as a output (not connected).
				if not node.has_connection(target.get_index(), node.outputs):
					# If [Target] does not have [Node] as a output
					if not target.outputs.has(node.get_index()):
						if not (node == target):
							node.add_connection(target.get_index(), node.outputs)
							target.add_connection(node.get_index(), target.inputs)

					# Else, replace exusting connection
					else:
						node.swap_connection(target.get_index(), node.inputs, node.outputs)
						target.swap_connection(node.get_index(), target.outputs, target.inputs)
						node.queue_redraw()  # Refresh the origin node
						target.queue_redraw()
				# Else, remove existing connection
				else:
					node.remove_connection(target.get_index(), node.outputs)
					target.remove_connection(node.get_index(), target.inputs)


func _on_node_moved(node):
	node.queue_redraw()
	for i in node.inputs:
		node = get_input_output_node(i)
		if node: node.queue_redraw()
	nodes[node.get_index()] = node.position
	queue_redraw()


func toggle_editing():
	var tree_map = PluginState.selected_tree_map
	tree_map.editing = !tree_map.editing
	if tree_map.editing:
		edited_nodes = get_tree_map_nodes_from(EditorInterface.get_selection().get_transformable_selected_nodes())
		EditorInterface.get_editor_toaster().push_toast("Editing enabled", EditorToaster.SEVERITY_INFO)
	else:
		edited_nodes.clear()
		EditorInterface.get_editor_toaster().push_toast("Editing disabled", EditorToaster.SEVERITY_INFO)


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
