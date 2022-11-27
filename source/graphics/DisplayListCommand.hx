package graphics;

import h2d.Layers;
import graphics.ParentID;
import graphics.LayerID;
import h2d.Object;

enum DisplayListCommand {
     ADD_PARENT(parent:Layers, tag:ParentID);
     ADD_TO(child:Object, parent:ParentID, layer:LayerID);
	REMOVE_FROM_PARENT(child:Object);
	PARENTS_SET_UP;
}