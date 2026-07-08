@tool
class_name TreeMap
extends Node2D


signal node_added (node: TreeMapNode)
signal node_removed (node: TreeMapNode)

signal selection_changed
signal notify_cleanup (node)


enum EditStates { NONE, EDITING, ADDING, REMOVING }

@export var edit_state: EditStates = EditStates.NONE  ## Internal use.
@export var chaining_enabled: bool = false  ## Internal use.

@export var selected_nodes: Array[Node] = []  ## Internal use.
@export var edited_nodes: Array[TreeMapNode] = []  ## Internal use.

@export var nodes: Array[Vector2] = []  ## The nodes within this TreeMap. Internal use.


@export_category("Customization")
@export var node_instance: PackedScene  ## (WIP) Specify a custom node type to use instead of the built-in TreeMapNode.
@export var min_length: int = 0  ## (WIP) Prevent placement of nodes within this radius of other nodes.
@export var max_length: int = 0  ## (WIP) Prevent placement of nodes outside this radius of other nodes.

#@export_tool_button("Sync Nodes")  ## Apply TreeMap customization settings on all children TreeMapNodes.
#@export_tool_button("Force Sync Nodes")  ## Apply TreeMap customization settings on all children TreeMapNodes. Ignores overrided customizations.

const default_color = Color.WHITE
const default_arrow_texture = preload("res://addons/tree_maps/icons/arrow_filled.png")
#@export_subgroup("Transforms")

@export_group("Nodes")
@export var node_color: Color = default_color
@export var node_size: float = 24.0  ## TreeMap only for now
@export_enum("Circle", "Square") var node_shape: String = "Circle"  ## (WIP) TreeMap only for now. Circle only.
@export var node_texture: Texture2D  ## Overrides node shape.
@export var node_modulate: Color  ## (WIP) TreeMap only for now. Modulates node color and texture.

@export_group("Lines")
@export var line_color: Color = default_color
@export var line_thickness: float = 10.0  ## TreeMap only for now.
@export var line_texture: Texture2D  ## (WIP) TreeMap only for now.
@export_subgroup("Lines Extra")
#@export var line_border_color: Color
#@export var line_fill_texture: Texture2D
#@export_enum("Normal", "Dashed") var line_style

@export_group("Arrows")
@export var arrow_color: Color = default_color
#@export var arrow_border_color: Color
#@export_enum("Default", "Thin", "Outline") var arrow_style: String = "Default"  ## (WIP) TreeMap only for now.
@export var arrow_texture: Texture2D = default_arrow_texture

# TODO:  Properties which are overriden will reset, if its the same as parent when editing parent's properties.

var setup_properties = [
		"node_color", "node_size", "node_texture", #"node_shape",
		"line_color", "line_thickness",
		"arrow_color", "arrow_texture"
	]


func _setup():
	nodes.clear()
	for child in get_children():
		if child is TreeMapNode:
			nodes.append(child.position)
			setup_tree_map_node(child)
	edit_state = TreeMap.EditStates.NONE  # Reset edit state.
	#print(nodes)


## Apply inherited properties to children TreeMapNodes
func setup_tree_map_node(node):
	for property in setup_properties:
		var parent_value = get(property)
		var parent_property = "parent_" + property
		# Before updating inherited properties, check if that property was actually inherited.
		# If it was, use inherited value as the default revert value for that property.
		if node.get(property) == node.get(parent_property):
			node.set(parent_property, parent_value)
			node.set(property, node.property_get_revert(property))
		else:
			node.set(parent_property, get(property))
	node.apply_properties()


func _ready() -> void:
	#if !Engine.is_editor_hint():
		_setup()
		#pass


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		#set_notify_transform(true)
		set_physics_process(true)
		Engine.get_singleton("EditorInterface").get_inspector().property_edited.connect( _on_property_edited )
		#Engine.get_singleton("EditorInterface").get_selection().selection_changed.connect( _on_selection_changed )  # Handled in plugin.gd
		child_entered_tree.connect( _on_child_entered_tree )
		child_exiting_tree.connect( _on_child_exiting_tree )
		selection_changed.connect( _on_selection_changed )
	_setup()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		Engine.get_singleton("EditorInterface").get_inspector().property_edited.disconnect( _on_property_edited )
		#Engine.get_singleton("EditorInterface").get_selection().selection_changed.disconnect( _on_selection_changed )
		child_entered_tree.disconnect( _on_child_entered_tree )
		child_exiting_tree.disconnect( _on_child_exiting_tree )
		selection_changed.disconnect( _on_selection_changed )
		nodes.clear()


func _draw():
	# Highlight all children node if TreeMap is selected.
	if selected_nodes.has(self):
		selected_nodes = get_tree_map_nodes()
	for node in selected_nodes:
		draw_circle(node.global_position, node.parent_node_size, Color("70bafa"), false, 4)


## https://forum.godotengine.org/t/in-godot-how-can-i-listen-for-changes-in-the-properties-of-nodes-within-the-editor-additionally-how-can-this-be-used-in-a-plugin/35330/4
#func _notification(what):
	#if what == NOTIFICATION_TRANSFORM_CHANGED:
		#pass


func _physics_process(delta: float) -> void:
	#if viewport_2d_selected:
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			#print("ASKDM")
			pass


func _on_child_entered_tree(child: Node) -> void:
	if child is TreeMapNode:
		child.moved.connect( _on_node_moved )
		#child.connections_edited.connect( _on_node_connections_edited )
		# Adjust saved indexes for child items' connections
		
		#if child


func _on_child_exiting_tree(child: Node) -> void:
	if child is TreeMapNode:
		child.moved.disconnect( _on_node_moved )
		selected_nodes.erase(child)
		
		if nodes.has(child.position):  # Clear node entry if node was deleted manually through the scene tree.
			nodes.erase(child.position)
		queue_redraw()
		#child.connections_edited.disconnect( _on_node_connections_edited )
		#notify_cleanup.emit()
		
		# Adjust saved indexes for child items' connections
		#remove_tree_map_node(child)
		#nodes.erase(child.position)
		#print("exited")


# Refresh/update properties on children
func _on_property_edited(property) -> void:
	if Engine.get_singleton("EditorInterface").get_inspector().get_edited_object() == self:
		if setup_properties.has(property):
			for node in get_tree_map_nodes():
				setup_tree_map_node(node)


func _on_selection_changed() -> void:
	var tree_map_nodes = get_tree_map_nodes_from(selected_nodes)
	#print(self, " - ", tree_map_nodes)

	match edit_state:
		EditStates.EDITING:
			# [Check for nodes to connect FROM] and [Check for nodes to connect TO]
			if edited_nodes.size() >= 1 and tree_map_nodes.size() >= 1:
				for node in edited_nodes:
					var target: TreeMapNode = tree_map_nodes[0]
					
					if not node.is_locked and not target.is_locked:
						# A edited node cannot target itself for an edit action.
						if not (node == target):
							# If [node] has existing connetion, remove connection.
							if node.has_connection(target.get_index(), node.outputs):
								disconnect_nodes([node], target)

							# Check if [node] does not already have [target] as a output, then connect to [target].
							# if [node] has [target] as an output, then it is already connected to it.
							elif not target.outputs.has(node.get_index()):
								connect_nodes([node], target)
								#else:
									#print("return")
									#return  # Ignore all other instructions.

							# Else swap connection directions.
							else:
								node.swap_connection(target.get_index(), node.inputs, node.outputs)
								target.swap_connection(node.get_index(), target.outputs, target.inputs)
								node.queue_redraw()  # Refresh the origin node.
								target.queue_redraw()  # Refresh the target node.
							
							## TODO: Fix select loop
							#if chaining_enabled:
								## Select targeted node if chaining is enabled.
								#edit_node(target)
							#else:
								## Reselect origin node if chaining is disabled.
								#select_node(node)
					else:
						Engine.get_singleton("EditorInterface").get_editor_toaster().push_toast("A node is locked. Ignoring connection edit.", EditorToaster.SEVERITY_INFO)
						
					if chaining_enabled:  # Select targeted node if chaining is enabled.
						edit_node(target)
					else:  # Reselect origin node if chaining is disabled.
						select_node(node)
		
		EditStates.ADDING:
			# TODO: if TreeMap is selected, add nodes without connections
			# TODO: Fix node not applyning inherited colors
			if tree_map_nodes.is_empty():  # Empty spot selected
				var new_node = add_tree_map_node()
				setup_tree_map_node(new_node)
				#new_node.apply_properties()
				if chaining_enabled:  # Automatically selects and connects the new node.
					for node in edited_nodes:
						connect_nodes([node], new_node)
					edit_node(new_node)  # select newly created node if chaining is enabled.
				else:  select_node(new_node)  # select newly created node

		EditStates.REMOVING:
			if !tree_map_nodes.is_empty():
				for target in tree_map_nodes:  # Remove all selected nodes
					if not target.is_locked:
						if target.get_parent() == self:  # Only allow targeting nodes who are this TreeMap's children
							# TODO Fix removal removing all nodes when selecting a TreeMapNode from another TreeMap directly from the Scene Tree.
							#print(target)
							#print(self)
							select_node(self)  # Reselect parent TreeMap to make removing nodes clean.
							remove_tree_map_node(target).queue_free()
					else:
						Engine.get_singleton("EditorInterface").get_editor_toaster().push_toast("A node is locked. Ignoring removal.", EditorToaster.SEVERITY_INFO)


func _on_node_moved(node):
	node.queue_redraw()
	for i in node.inputs:
		node = get_input_output_node(i)
		if node: node.queue_redraw()
	nodes[node.get_index()] = node.position
	#var copy = nodes.duplicate()
	#copy[node.get_index()] = node.position
	#nodes = copy
	queue_redraw()


func refresh():
	#for i in get_
	pass
	

func update_property():
	pass


func toggle_editing(state: bool):
	if state == true:
		# Add currently selected TreeMapNodes to editing selection
		for i in Engine.get_singleton("EditorInterface").get_selection().get_top_selected_nodes():
			if i is TreeMapNode: self.edited_nodes.append(i)
		edit_state = TreeMap.EditStates.EDITING
		Engine.get_singleton("EditorInterface").get_editor_toaster().push_toast("Editing enabled", EditorToaster.SEVERITY_INFO)
	else:
		edited_nodes.clear()
		Engine.get_singleton("EditorInterface").get_editor_toaster().push_toast("Editing disabled", EditorToaster.SEVERITY_INFO)


func toggle_adding(state: bool):
	if state == true:
		# Add currently selected TreeMapNodes to editing selection
		for i in Engine.get_singleton("EditorInterface").get_selection().get_top_selected_nodes():
			if i is TreeMapNode: self.edited_nodes.append(i)
		edit_state = TreeMap.EditStates.ADDING
	else:
		Engine.get_singleton("EditorInterface").get_editor_toaster().push_toast("Adding disabled", EditorToaster.SEVERITY_INFO)


func toggle_removing(state: bool):
	if state == true:
		edit_state = TreeMap.EditStates.REMOVING
		select_node(self)  # Select parent TreeMap to make removing nodes clean.
	else:
		Engine.get_singleton("EditorInterface").get_editor_toaster().push_toast("Removing disabled", EditorToaster.SEVERITY_INFO)


func toggle_chaining():
	chaining_enabled = !chaining_enabled
	if chaining_enabled:
		Engine.get_singleton("EditorInterface").get_editor_toaster().push_toast("Chaining enabled", EditorToaster.SEVERITY_INFO)
	else:
		Engine.get_singleton("EditorInterface").get_editor_toaster().push_toast("Chaining disabled", EditorToaster.SEVERITY_INFO)


func toggle_locking():
	var lock_statuses = selected_nodes.map( func(node): return node.is_locked )
	if lock_statuses.has(false) and lock_statuses.has(true):
		for node in selected_nodes:
			node.is_locked = true
			node.queue_redraw()
	else:
		for node in selected_nodes:
			node.is_locked = !node.is_locked
			node.queue_redraw()		
	


func add_tree_map_node() -> TreeMapNode:
	var tree_map_node = TreeMapNode.new()
	add_child(tree_map_node)
	tree_map_node.global_position = get_global_mouse_position()
	tree_map_node.owner = Engine.get_singleton("EditorInterface").get_edited_scene_root()
	tree_map_node.name = tree_map_node.get_script().get_global_name()
	nodes.append(tree_map_node.position)
	return tree_map_node


func remove_tree_map_node(node) -> TreeMapNode:
	print("removed")
	var idx = node.get_index()
	#nodes.erase(node.position)
	var copy = nodes.duplicate()
	copy.erase(node.position)
	nodes = copy
	
	for i in node.inputs:  # Remove idx from output connection lists
		get_child(i).outputs.erase(idx)
		get_child(i).queue_redraw()
	for i in node.outputs:  # Remove idx from input connection lists
		get_child(i).inputs.erase(idx)
		get_child(i).queue_redraw()
	remove_child(node)
	queue_redraw()
	return node


## Connects all specified nodes to the target node.
func connect_nodes(connecting_nodes: Array[TreeMapNode], target_node: TreeMapNode):
	for connecting_node in connecting_nodes:
		connecting_node.add_connection(target_node.get_index(), "outputs")
		target_node.add_connection(connecting_node.get_index(), "inputs")


## Disconnects all of the specified nodes from the target node.
func disconnect_nodes(disconnecting_nodes: Array[TreeMapNode], target_node: TreeMapNode):
	for disconnecting_node in disconnecting_nodes:
		disconnecting_node.remove_connection(target_node.get_index(), disconnecting_node.outputs)
		target_node.remove_connection(disconnecting_node.get_index(), target_node.inputs)


## Add the node to selection
func select_node(node):
	Engine.get_singleton("EditorInterface").get_selection().clear()
	Engine.get_singleton("EditorInterface").get_selection().add_node(node)


## Adds the nodes to selection
func select_nodes(nodes: Array):
	Engine.get_singleton("EditorInterface").get_selection().clear()
	for node in nodes:
		Engine.get_singleton("EditorInterface").get_selection().add_node(node)


## Add the node to selection and set as actively edited by plugin.
func edit_node(node):
	Engine.get_singleton("EditorInterface").get_selection().clear()
	Engine.get_singleton("EditorInterface").get_selection().add_node(node)
	edited_nodes.clear()
	edited_nodes.append(node)


#func swap_node_connection(idx, old_array, new_array):
	#old_array.erase(idx)
	#new_array.append(idx)


## Returns the child TreeMapNode at index idx.
func get_tree_map_node(idx: int) -> TreeMapNode:
	return get_child(idx)


## Returns all TreeMapNode children belonging to this TreeMap.
func get_tree_map_nodes() -> Array[Node]:
	return Array( get_children().map( func(node): if node is TreeMapNode: return node ), TYPE_OBJECT, "Node", null )


## Returns an array of all [TreeMapNodes] in [array]
func get_tree_map_nodes_from(array: Array[Node]) -> Array[TreeMapNode]:
	var tree_map_nodes: Array[TreeMapNode] = []
	for node in array:
		if node is TreeMapNode:
			tree_map_nodes.append(node)
	return tree_map_nodes


func get_last_selected_node() -> TreeMapNode:
	var last_selection
	var selected_nodes = Engine.get_singleton("EditorInterface").get_selection().get_top_selected_nodes()
	for i in selected_nodes.size():
		last_selection = selected_nodes[-i-1]
		if last_selection is TreeMapNode:
			break
	return last_selection


func get_input_output_node(idx):
	if self.get_child_count() >= idx + 1:
		return self.get_child(idx)
