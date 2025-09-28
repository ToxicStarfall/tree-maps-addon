
<!-- image here -->
<!-- ![Annotation](url)-->
<h2 align="center">
	Tree Maps - Graphs and Skill Trees
</h2>
<p align="center">
	Tree Maps provides useful nodes and functionality to help create graphical maps of tree-like node structures.
</p>

<br/><br/>

<p align="center">
	<a href="https://godotengine.org/asset-library/">Godot Asset Library</a> -
	<a href="https://github.com/ToxicStarfall/skill-tree-addon/releases">Releases</a>
</p>

#

<br>
<h3>About</h3>

<br>
<h3>Download & Installation</h3>
There are two options to install this addon:
<ol>
	<li>Through the built-in AssetLib tab in Godot.</li>
	<li>Manually download and put it in your project's "addons" folder.</li>
</ol>

<br>
<h3>Usage</h3>

This addon adds two new custom nodes which both inherit from `Node2D`: `TreeMap` and `TreeMapNode`
<br><br>

Starting in 2D view, add a new `TreeMap` to your scene, positioned at the origin.

> Note: Positioning the `TreeMap` node anywhere else will effect drawing of `TreeMapNodes`.

This is will be the main focus point of this addon.
<br><br>

`TreeMap` comes with several custom properties in the Inspector.
By default, these properties will be passed down to any children `TreeMapNode`s.
These properties will effect how `TreeMapNode` childs will be displayed and/or interact.

From here, you can now add `TreeMapNode` as a child of the `TreeMap`.
> Note: It is highly recommended to have `TreeMapNode` be children of `TreeMap`.
> By continueing without `TreeMap`, there **WILL** be errors.

<br><br>
As you can see, `TreeMapNode` also comes with its own custom properties.
Editing any properties within the "Overrides" section will result in that `TreeMapNode` having that
property seperate from its parent `TreeMap`. To reset it to its default inherited property, simply
reset the property.
<br><br>

Upon selecting a `TreeMap` or `TreeMapNode`, you can see in the tool bar at the top will change,
showing some new tool buttons. These will allow you to edit your `TreeMapNode`(s)

<h4>Main Tools</h4>
Right click to disable active tool.

- Edit Connections:
	Click to create connection.
	If there is a existing connection, remove it instead.
	If there is a existing connection poiting towards the selected node, swap pointing direction.
- Add Nodes - Click to create a `TreeMapNode` at mouse click
- Remove Nodes - Removes the selected node.

<h4>Modifiers</h4>
- Chaining (WIP) - selects the targeted node after using a tool

<h4>Miscellaneous</h4>
- Info (WIP)


_to be continued..._
<br><br>

**Demo video**

https://github.com/user-attachments/assets/fbfc2732-9639-446d-b620-4464e99fa997


<br>
<h3>Examples</h3>
