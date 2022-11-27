package damage;

import graphics.RenderCommand;
import command.Command;
import graphics.Animation;
import graphics.Spritesheet;
import ecs.Universe;
import ecs.Entity;

abstract CritUI(Entity) to Entity {
	
	public function new(type:String, ecs:Universe, sheet:Spritesheet) {
		this = ecs.createEntity();
		
		var anim = new Animation();
		anim.add({
			name : "default",
			loop : false,
			fps : 1,
			frames : sheet.map([type])
		});
		anim.play("default");
		
		ecs.setComponents(this, anim);
		Command.queue(ALLOC_SPRITE(this, MAIN));
	}
}