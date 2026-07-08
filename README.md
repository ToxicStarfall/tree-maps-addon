
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
	<a href="https://github.com/ToxicStarfall/skill-tree-addon/releases">Releases (more up to date)</a> - 
	<a href="https://godotengine.org/asset-library/asset/4362">Godot Asset Library</a>
</p>

#

<h2>About</h2>
One day while trying to make a very large technology tree, I found that I was having trouble creating a system
which would allow me quickly expand and add lots of different upgrades and paths. To simplify this process
I decided to create Tree Maps in order to adress some of the complications behind creating tech/skill trees.
<br><br>
Currently, this remains a relatively simple addon, however I plan to continue adding features in order to help with
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
> [!NOTE]
> Positioning the `TreeMap` node anywhere else will effect drawing of `TreeMapNodes`.
<br>

Upon selecting the new `TreeMap` node, some new tools will become available in the tool bar.
A new `TreeMapNode` can be added with the "Add Nodes" tool. see [Main Tools](#main-tools) for more info.
New `TreeMapNode`s can be moved around normally in the 2D View.

> [!NOTE]
> You can add nodes manually, however you will have to refresh the Scene Tree (Reload scene, or Open and Close the scene).

> [!WARNING]
> It is highly recommended to have ONLY `TreeMapNode` be direct children of `TreeMap`.
> Using nodes which are not and do not inherit from `TreeMapNode` **will** result in errors.
<br>

Both `TreeMap` and `TreeMapNode` come with several customizable properties in the Inspector.
By default, `TreeMap`'s properties will be passed down to any children `TreeMapNode`s.
These properties will effect how `TreeMapNode` childs will be displayed and/or interact.

Editing any properties within a `TreeMapNode`'s "Overrides" section will result in that `TreeMapNode` having its own
property seperate from its parent `TreeMap`. Changes to the `TreeMap`'s properties will not affect it. To reset it to its default inherited property, simply
reset the property normally.
<br>

Upon selecting a `TreeMap` or `TreeMapNode`, you can see in the tool bar at the top will change,
showing some new tool buttons. These will allow you to edit your `TreeMapNode`(s)
<br><br>

<a href="#main-tools">
	<h3>Main Tools</h3>
</a>
<img width="218" height="37" alt="tree-maps-tools" src="https://github.com/user-attachments/assets/48c3f2ca-9a48-40e8-ad83-9c43c4e791ad" />

> [!NOTE]
> When activating a tool, the currently selected node is your main node, from which tools
> will act from. Selecting another node while your tool is active will make that the target node.
> To select a different node to edit from, simply deactivate the tool, then select your new node
> and reactivate the tool.

- **Edit Connections** - <br>
	- Select a node to create a new connection to it.<br>
	- If there is a existing connection, remove it instead.<br>
	- If there is a existing connection pointing towards the origin node, swap pointing direction.
- **Add Nodes** - Click to add a new `TreeMapNode` at the current mouse position in 2D View.
- **Remove Nodes** - Removes the selected node.

> [!TIP]
> Right click to disable the active main tool.

> [!WARNING]
> Selecting and targeting nodes directly in the scene tree with a tool works, however it is more bug/error prone.
> Use the 2D View to select and target nodes with tools instead.


<h3>Modifiers</h3>
Modifiers change the way the Main Tools behave.<br>

- **Chaining** - selects the targeted node after using a tool (if applicable).
- **Lock/Unlock** - disable/enables editing of the selecetd node(s). 

> [!TIP]
> Tools and Modifiers can be used to select and target multiple nodes at once!

> [!TIP]
> Use the Chaining modifier to easily connect or disconnect a series of nodes. 

<h3>Miscellaneous</h3>

- **Reset (WIP)** - resets all of the selected node's properties to the default inherited values.
- **Info (WIP)** - Shows helpful info
<br><br>


<br>
<h2>Examples</h2>

**Demo video**

https://github.com/user-attachments/assets/fbfc2732-9639-446d-b620-4464e99fa997

<img width="381" height="126" alt="tree-maps-example-2" src="https://github.com/user-attachments/assets/ab330c81-42a5-4f5b-bc32-5a264385f1d3" />
<br>
<img width="581" height="425" alt="tree-maps-example-3" src="https://github.com/user-attachments/assets/88cd6851-7516-44ab-858e-bdcbc8a53077" />


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
