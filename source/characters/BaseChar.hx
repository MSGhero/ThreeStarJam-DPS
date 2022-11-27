package characters;

import graphics.RenderCommand;
import command.Command;
import ecs.Entity;

@:forward
abstract BaseChar(Entity) to Entity {
	
	//public var attacks(default, null):Vector<BaseAttack>; // each unit has N attacks that follow standard pattern
	
	public function new(id:Entity) {
		this = id;
		Command.queue(ALLOC_SPRITE(this, MAIN)); // this is the only compo that doesn't really need to be configured
	}
}