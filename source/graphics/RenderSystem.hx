package graphics;

import h2d.Layers;
import h2d.SpriteBatch;
import haxe.ds.IntMap;
import ecs.Entity;
import command.Command;
import ecs.Universe;
import ecs.System;

class RenderSystem extends System {
	
	@:fullFamily
	var sprites : {
		resources : {
			
		},
		requires : {
			sprite:Sprite
		}
	};
	
	var sheetMap:IntMap<Spritesheet>;
	var batchMap:IntMap<SpriteBatch>;
	var parentMap:IntMap<Layers>;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		sheetMap = new IntMap();
		batchMap = new IntMap();
		parentMap = new IntMap();
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		Command.register(RenderCommand.ADD_SHEET(null, MAIN), handleRC);
		Command.register(RenderCommand.CREATE_BATCH(MAIN, MAIN, S2D, DEFAULT), handleRC);
		Command.register(RenderCommand.ALLOC_SPRITE(Entity.none, MAIN), handleRC);
		
		Command.register(DisplayListCommand.ADD_PARENT(null, S2D), handleDLC);
		Command.register(DisplayListCommand.ADD_TO(null, S2D, DEFAULT), handleDLC);
	}
	
	function handleRC(rc:RenderCommand) {
		
		switch (rc) {
			case ADD_SHEET(sheet, id):
				sheetMap.set(id, sheet);
			case CREATE_BATCH(sheet, tag, parentTag, layer):
				var batch = new SpriteBatch(sheetMap.get(sheet).get("default"));
				batchMap.set(tag, batch);
				Command.queue(DisplayListCommand.ADD_TO(batch, parentTag, layer));
			case ALLOC_SPRITE(entity, from):
				var elt = batchMap.get(from).alloc(null); // the animation will set the tile properly
				universe.setComponents(entity, (elt:Sprite));
			default:
		}
	}
	
	function handleDLC(dlc:DisplayListCommand) {
		
		switch (dlc) {
			case ADD_PARENT(parent, tag):
				parentMap.set(tag, parent);
			case ADD_TO(child, parent, layer):
				parentMap.get(parent).addChildAt(child, layer);
			default:
		}
	}
}