
<h1 align="center">
	Tree Maps - Graphs and Skill Trees
</h1>
<p align="center">
	Tree Maps provides useful nodes and functionality to help create graphical maps of tree-like node structures.
	<br>
	Perfect for skill trees, technology trees, and or dungeon maps.
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
	<li>Downloading manually, unpack it, and put it in your project's "addons" folder.</li>
</ol>

<h3>Option 1 - Download through Godot's AssetLib tab</h3>
Note: The addon may still be pending in the Asset Library.

<ol>
	<li>Simply open your Godot project, select the "AssetLib" tab, and search "TreeMap"</li>
	<li>Select it and download, then install. Afterwards simply enable it in ProjectSettings's Plugins tab.</li>
</ol>

<h3>Option 2 - Download manually</h3>
<ol>
	<li>Go to repository and download a release (tree-maps-addon.zip)</li>
	<li>Unpack the zip (make sure you don't duplicate the root folder)</li>
	<li>Simply move the addon (tree-maps) to the addons folder of your project's root (create one if your missing it).</li>
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

From here, you can now add `TreeMapNode` as a child of the `TreeMap`, see [Main Tools](#main-tools)
for the "Add Nodes" tool.
> Note: You can add nodes manually, however you will have to refresh the Scene Tree (Reload scene, or Open and Close the scene).

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


<a href="#main-tools">
	<h3>Main Tools</h3>
</a>
<em>Tip: Right click to disable the active main tool.</em><br>

> Note: When activating a tool, the currently selected node is your main node, from which tools
> will act from. Selecting another node while your tool is active will make that the target node.
> To select a different node to edit from, simply deactivate the tool, then select your new node
> and reactivate the tool.

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

- **Reset (WIP)** - resets the selected node's properties to the default inherited values.
- **Info (WIP)** - Shows helpful info
<br><br>


<br>
<h2>Examples</h2>

**Demo video**

https://github.com/user-attachments/assets/fbfc2732-9639-446d-b620-4464e99fa997


<br>
<h2>What's Next?</h2>
Currently there is a somewhat limited amount of customization options available for TreeMap and TreeMapNode.

I still plan to continue adding some more customization features along with more helpful tools. I already have several in mind.

However, if you find that there is a missing feature you want, this is where you can extend the TreeMapNode class and add your own code!
If you think it could be a core feature, feel free to create a issue in the repository.
<br>

<h3>Planned Features</h3>
TreeMap

	- Min/Max line length - prevent node placement or movement within min/max distance of another node.
	- NodeInstance - use your own extended node for the "Add Nodes" tool.
<br>
<h3>Potential Features</h3>
These features are still being decided on. If enough people really want this, I will consider adding.

- Bezier curves, and Arcs
