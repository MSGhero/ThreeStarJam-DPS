package graphics;

import ecs.Entity;
import graphics.Spritesheet;
import graphics.SpritesheetID;
import graphics.ParentID;
import graphics.LayerID;
import graphics.BatchID;

enum RenderCommand {
	// more like batch/sprite command
	ADD_SHEET(sheet:Spritesheet, id:SpritesheetID);
	CREATE_BATCH(sheet:SpritesheetID, tag:BatchID, parentTag:ParentID, layer:LayerID);
	ALLOC_SPRITE(entity:Entity, from:BatchID);
}