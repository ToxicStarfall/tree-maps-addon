@tool
class_name TreeMap
extends Node2D

signal notify_cleanup(node)

@export var selected_nodes: Array = []
@export var selected_node: TreeMapNode
#@export var tree_items: Array = []
@export var nodes: Array[Vector2] = []

#@export var node_instance: PackedScene
#@export var min_length: int = 0
#@export var max_length: int = 0

@export_group("Overrides")
#const DEFAULT_COLOR = Color.WHITE
#@export_subgroup("Transform")
#@export_subgroup("Nodes")
#@export var node_texture: Color
#@export var node_color: Color
#@export_subgroup("Lines")
#@export var line_color: Color
#@export var line_fill_color: Color
#@export var line_texture: Texture2D
#@export var line_fill_texture: Texture2D
#@export_subgroup("Arrows")
#@export var arrow_fill_color: Color
#@export var arrow_texture: Texture2D


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)
		child_entered_tree.connect( _on_child_entered_tree )
		child_exiting_tree.connect( _on_child_exiting_tree )
		EditorInterface.get_selection().selection_changed.connect( _on_selection_changed )


func _exit_tree() -> void:
	child_entered_tree.disconnect( _on_child_entered_tree )
	child_exiting_tree.disconnect( _on_child_exiting_tree )
	EditorInterface.get_selection().selection_changed.disconnect( _on_selection_changed )


## https://forum.godotengine.org/t/in-godot-how-can-i-listen-for-changes-in-the-properties-of-nodes-within-the-editor-additionally-how-can-this-be-used-in-a-plugin/35330/4
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		#queue_redraw()
		pass


func _draw() -> void:
	#for i in nodes:
		#draw_circle(i, 2, Color.RED, true)
	pass


func _on_child_entered_tree(child: Node) -> void:
	if child is TreeMapNode:
		child.moved.connect( _on_node_moved )
		child.connections_edited.connect( _on_node_connections_edited )
		nodes.append(child.position)
		# Adjust saved indexes for child items' connections


func _on_child_exiting_tree(child: Node) -> void:
	if child is TreeMapNode:
		notify_cleanup.emit()
		child.moved.disconnect( _on_node_moved )
		child.connections_edited.disconnect( _on_node_connections_edited )
		nodes.clear()
		# Adjust saved indexes for child items' connections


func _on_selection_changed() -> void:
	var selected_nodes = EditorInterface.get_selection().get_transformable_selected_nodes()
	for node in selected_nodes:
		if node != TreeMapNode:
			break
		else:
			pass
	if selected_nodes:
		if selected_node:
			var new_connections = selected_node.outputs.duplicate()
			if PluginState.is_editing:
				var connection_target = get_last_selected_node()
				var connection_target_idx = connection_target.get_index()
				# Prevent duplicates and self from being included
				if !new_connections.has(connection_target_idx) and !(selected_node == connection_target):
					new_connections.append( connection_target.get_index() )
					selected_node.add_connection(connection_target_idx, true)
					connection_target.add_connection(selected_node.get_index(), false)
				#selected_node.outputs = new_connections
		#else:
			#EditorInterface.get_editor_toaster().push_toast("Please select a node", EditorToaster.SEVERITY_WARNING)
	elif selected_node:
		selected_node.toggle_editing_connections()
		selected_node = null
		#EditorInterface.get_editor_toaster().push_toast("Editing disabled", EditorToaster.SEVERITY_INFO)


func _on_node_connections_edited(node) -> void:
	selected_node = node


func _on_node_moved(node):
	node.queue_redraw()
	for i in node.inputs:
		node = get_input_output_node(i)
		if node: node.queue_redraw()
	nodes[node.get_index()] = node.position
	queue_redraw()


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


func get_points_from_nodes(nodes: Array):
	pass
