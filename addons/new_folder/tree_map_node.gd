@tool
class_name TreeMapNode
extends Node2D

signal moved
signal connections_edited


@export var outputs: Array[int] = []
@export var inputs: Array[int] = []

@export var locked: bool = false
#@export_category("Customization")
#@export var data: Resource


@export_group("Overrides")
# Defaults are overidden by TreeMap parent.
# Default Properties
var default_node_color = Color.WHITE
var default_line_color = Color.WHITE
var default_arrow_color = Color.WHITE
var default_arrow_texture = preload("res://addons/new_folder/icons/arrow_filled.png")
# Inherited TreeMap Properties
var parent_line_color: Color
# Internal Usage Properties
var internal_line_color = default_line_color
# Editable Override Properties
@export var node_color: Color = Color.WHITE
@export var line_color: Color = default_line_color
@export var arrow_color: Color = Color.WHITE  ## Modulates default texture color
@export var arrow_texture: Texture2D = preload("res://addons/new_folder/icons/arrow_filled.png")


func _setup():
	# If no override property is specified, then use inherited property.
	#if !node_color: default_node_color = node_color
	if !line_color: internal_line_color = parent_line_color
	#if !arrow_color: default_arrow_color = arrow_color
	#if !arrow_texture: default_arrow_texture = arrow_texture
	# If no inherited property is specified, then use Default property.
	if !parent_line_color: internal_line_color = default_line_color


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)
		EditorInterface.get_inspector().property_edited.connect( _on_property_edited )
	_setup()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		EditorInterface.get_inspector().property_edited.disconnect( _on_property_edited )


func _draw() -> void:
	_draw_connection()
	_draw_node()


func _draw_connection():
	for i in outputs:
		draw_set_transform(Vector2(0,0), 0)  # Reset drawing position
		var target_pos = get_parent().get_child(i).global_position
		draw_line(Vector2(0,0) , target_pos - self.global_position, internal_line_color, 10)

		var arrow_texture = arrow_texture
		var arrow_pos = (target_pos - self.position) / 2  # Get half-way point between nodes
		var arrow_ang = (target_pos - position).angle()   # Get angle pointing towards next connecting node
		draw_set_transform(arrow_pos, arrow_ang)  # Set draw offset to arrow position to make it the center rotating point
		draw_texture(arrow_texture, -arrow_texture.get_size() / 2, arrow_color)


func _draw_node():
	draw_set_transform(Vector2(0,0), 0)
	draw_circle(Vector2(0,0), 12, node_color, true)


func _notification(what) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		moved.emit(self)


func _property_can_revert(property: StringName) -> bool:
	match property:
		"line_color":#, "node_color":
			return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	match property:
		"line_color":
			return parent_line_color
	return


#
func _on_property_edited(property: String):
	if EditorInterface.get_inspector().get_edited_object() == self:
		if property == "line_color":
			apply_properties()


# Update properties
func apply_properties():
	print("updating properties")
	if line_color == parent_line_color: internal_line_color = parent_line_color
	else: internal_line_color = line_color
	queue_redraw()


#func toggle_editing_connections():
	#pass


## Adds a idx for node connections.
func add_connection(idx: int, connection_array: Array[int]):
	connection_array.append(idx)
	queue_redraw()

## Removes idx from node's connection_array
func remove_connection(idx: int, connection_array: Array[int]):
	connection_array.erase(idx)
	queue_redraw()


func swap_connection(idx, old_array, new_array):
	old_array.erase(idx)
	new_array.append(idx)


# Returns true/false if the Input/Output array has int value of "idx"
func has_connection(idx: int, connection_array: Array[int]):
	return connection_array.has(idx)


func extend():
	pass
