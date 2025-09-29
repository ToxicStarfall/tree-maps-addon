
<!-- image here -->
<!-- ![Annotation](url)-->
<h1 align="center">
	Tree Maps - Graphs and Skill Trees
</h1>
<p align="center">
	Tree Maps provides useful nodes and functionality to help create graphical maps of tree-like node structures.
</p>
<img width="1027" height="428" alt="image" src="https://github.com/user-attachments/assets/33846207-1cb2-458d-8d88-33f94e250fa7" />

<br>
<p align="center">
	<a href="https://godotengine.org/asset-library/">Godot Asset Library</a> -
	<a href="https://github.com/ToxicStarfall/skill-tree-addon/releases">Releases</a>
</p>

#

<h2>About</h2>
One day while trying to make a very large technology tree, I found that I was having trouble creating a system
which would allow me quickly expand and add lots of different upgrades and paths. To simplify this process
I decided to create Tree Maps in order to adress some of the complications behind creating tech/skill trees.
<br><br>
Currently, this remains a very simple addon, however I plan to continue adding features in order to help with
creating fully fledged skill and technology trees.
<br><br>

<h2>Download & Installation</h2>
There are two options to install this addon:
<ol>
	<li>Through the built-in AssetLib tab in Godot.</li>
	<li>Download the zip file manually, unpack it, and put it in your project's "addons" folder.</li>
</ol>

<br>
<h2>Usage</h2>

This addon adds two new custom nodes which both inherit from `Node2D`: `TreeMap` and `TreeMapNode`
<br><br>

Starting in 2D view, add a new `TreeMap` to your scene, positioned at the origin.

> Note: Positioning the `TreeMap` node anywhere else will effect drawing of `TreeMapNodes`.
> Will be fixed later.
<br>

`TreeMap` comes with several custom properties in the Inspector.
By default, these properties will be passed down to any children `TreeMapNode`s.
These properties will effect how `TreeMapNode` childs will be displayed and/or interact.

From here, you can now add `TreeMapNode` as a child of the `TreeMap`.
> Note: It is highly recommended to have `TreeMapNode` be children of `TreeMap`.
> By continueing without `TreeMap`, there **WILL** be errors.
<br>

Editing any properties within the "Overrides" section will result in that `TreeMapNode` having its own
property seperate from its parent `TreeMap`. To reset it to its default inherited property, simply
reset the property normally.
<br><br>

Upon selecting a `TreeMap` or `TreeMapNode`, you can see in the tool bar at the top will change,
showing some new tool buttons. These will allow you to edit your `TreeMapNode`(s)
<br>


<h3>Main Tools</h3>
<img width="218" height="37" alt="tree-maps-tools" src="https://github.com/user-attachments/assets/48c3f2ca-9a48-40e8-ad83-9c43c4e791ad" />

Right click to disable active tool.

- **Edit Connections**:
	Click to create connection.
	If there is a existing connection, remove it instead.
	If there is a existing connection poiting towards the selected node, swap pointing direction.
- **Add Nodes** - Creates a new `TreeMapNode` at mouse click.
- **Remove Nodes** - Removes the selected node.


<h3>Modifiers</h3>
These tools change the way Main Tools behave.

- **Chaining** - selects the targeted node after using a tool (if applicable).
- **Lock/Unlock (WIP)** - disables editing of the selecetd node(s).


<h3>Miscellaneous</h3>

- **Info (WIP)** - Shows helpful info
<br><br>


_to be continued..._

<br>
<h2>Examples</h2>

**Demo video**

https://github.com/user-attachments/assets/fbfc2732-9639-446d-b620-4464e99fa997
