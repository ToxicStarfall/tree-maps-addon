@tool
class_name NodeTree
extends Node2D


@export var selected_nodes: Array = []
@export var selected_node: NodeTreeItem
@export var tree_items: Array = []
#var last_selection


func _init() -> void:
	pass


func _enter_tree() -> void:
	set_notify_transform(true)
	EditorInterface.get_selection().selection_changed.connect( _on_selection_changed )


## https://forum.godotengine.org/t/in-godot-how-can-i-listen-for-changes-in-the-properties-of-nodes-within-the-editor-additionally-how-can-this-be-used-in-a-plugin/35330/4
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		#queue_redraw()
		pass


func _draw() -> void:
	#draw_line($NodeTreeItem.position, $NodeTreeItem2.position, Color.WHITE, 10)
	pass


func _on_child_entered_tree(child: Node) -> void:
	if child is NodeTreeItem:
		child.moved.connect( _on_node_moved )
		child.connections_edited.connect( _on_node_connections_edited )
		# Adjust saved indexes for child items' connections


func _on_child_exiting_tree(child: Node) -> void:
	if child is NodeTreeItem:
		# Adjust saved indexes for child items' connections
		pass


func _on_selection_changed() -> void:
	var selected_nodes = EditorInterface.get_selection().get_transformable_selected_nodes()
	if selected_nodes:
		if selected_node:
			var new_connections = selected_node.outputs.duplicate()
			if selected_node.editing_connections:
				var connection_target = get_last_selected_node()
				var connection_target_idx = connection_target.get_index()
				# prevent duplicate and self from being included
				if !new_connections.has(connection_target_idx) and !(selected_node == connection_target):
					new_connections.append( connection_target.get_index() )
				selected_node.outputs = new_connections
		else:
			EditorInterface.get_editor_toaster().push_toast("Please select a node", EditorToaster.SEVERITY_WARNING)
	elif selected_node:
		selected_node.toggle_editing_connections()
		selected_node = null
		EditorInterface.get_editor_toaster().push_toast("Editing disabled", EditorToaster.SEVERITY_INFO)


func _on_node_connections_edited(node) -> void:
	selected_node = node


func _on_node_moved(node):
	node.queue_redraw()


func get_last_selected_node() -> NodeTreeItem:
	var last_selection
	var selected_nodes = EditorInterface.get_selection().get_transformable_selected_nodes()
	for i in selected_nodes.size():
		last_selection = selected_nodes[-i-1]
		if last_selection is NodeTreeItem:
			break
	return last_selection


func get_input_output_node(idx):
	if self.get_child_count() >= idx + 1:
		return self.get_child(idx)


func get_points_from_nodes(nodes: Array):
	pass
