package characters;

import api.APICommand;
import graphics.RenderCommand;
import command.Command;
import interactive.shapes.Circle;
import interactive.Interactive;
import graphics.Animation;
import graphics.Spritesheet;
import ecs.Universe;
import ecs.Entity;

@:transitive
abstract Boss(Entity) to Entity {
	
	public function new(ecs:Universe, sheet:Spritesheet) {
		this = ecs.createEntity();
		
		var anim = new Animation();
		anim.add({
			name : "idle",
			loop : false,
			fps : 1,
			frames : sheet.map(["shield_idle"])
		})
		.add({
			name : "def_soft",
			loop : false,
			fps : 6,
			frames : sheet.map(["shield_idle", "shield_defend_soft", "shield_defend_soft", "shield_idle"])
		})
		.add({
			name : "def_hard",
			loop : false,
			fps : 6,
			frames : sheet.map(["shield_idle", "shield_defend_hard", "shield_defend_hard", "shield_idle"])
		})
		;
		
		anim.play("idle");
		
		var int:Interactive = {
			shape : new Circle(157 - 22, 270 - 22, 60),
			enabled : true,
			onOver: () -> hxd.System.setCursor(Button),
			onOut: () -> hxd.System.setCursor(Default),
			onSelect: () -> Command.queue(UNLOCK_MEDAL(71858))
		};
		
		ecs.setComponents(this, anim, int);
		Command.queue(ALLOC_SPRITE(this, MAIN));
	}
}