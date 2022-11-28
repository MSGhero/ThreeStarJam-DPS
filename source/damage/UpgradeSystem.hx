package damage;

import graphics.Spritesheet;
import graphics.Animation;
import interactive.shapes.Circle;
import interactive.Interactive;
import h2d.Font;
import attacks.CritInfo;
import graphics.Sprite;
import timing.Tweener;
import timing.TimingCommand;
import timing.Updater;
import graphics.DisplayListCommand;
import hxd.res.DefaultFont;
import h2d.Text;
import characters.Character;
import haxe.ds.Vector;
import haxe.Timer;
import ecs.Entity;
import attacks.AttackCommand;
import command.Command;
import ecs.Universe;
import ecs.System;
import graphics.RenderCommand;

class UpgradeSystem extends System {
	
	@:fullFamily
	var characters : {
		resources : {
			sheet:Spritesheet,
			hype:Hype
		},
		requires : {
			char:Character,
			color:Int,
			critInfo:CritInfo
		}
	};
	
	public function new(ecs:Universe) {
		super(ecs);
		
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		Command.register(PARENTS_SET_UP, handleDLC);
	}
	
	function handleDLC(dlc:DisplayListCommand) {
		
		switch (dlc) {
			case PARENTS_SET_UP:
				
				// new skill
				var skillInt:Interactive = {
					shape : new Circle(80 - 22, 430 - 22, 60),
					enabled : true,
					onOver: () -> hxd.System.setCursor(Button),
					onOut: () -> hxd.System.setCursor(Default),
					onSelect: () -> trace("new skill")
				};
				
				var skillText = new Text(DefaultFont.get());
				skillText.textAlign = Center;
				skillText.textColor = 0xff000000;
				skillText.text = "New Skill";
				skillText.x = 56;
				skillText.y = 458;
				
				// dmg/atk spd boost
				var dmgInt:Interactive = {
					shape : new Circle(185 - 22, 508 - 22, 60),
					enabled : true,
					onOver: () -> hxd.System.setCursor(Button),
					onOut: () -> hxd.System.setCursor(Default),
					onSelect: () -> trace("dmg+")
				};
				
				var dmgText = new Text(DefaultFont.get());
				dmgText.textAlign = Center;
				dmgText.textColor = 0xff000000;
				dmgText.text = "More damage";
				dmgText.x = 168;
				dmgText.y = 422;
				
				// crit boost
				var critInt:Interactive = {
					shape : new Circle(297 - 22, 430 - 22, 60),
					enabled : true,
					onOver: () -> hxd.System.setCursor(Button),
					onOut: () -> hxd.System.setCursor(Default),
					onSelect: () -> trace("crit+")
				};
				
				var critText = new Text(DefaultFont.get());
				critText.textAlign = Center;
				critText.textColor = 0xff000000;
				critText.text = "More crit";
				critText.x = 272;
				critText.y = 458;
				
				var ent = universe.createEntity();
				var anim = new Animation();
				
				setup(characters, {
					anim.add({ name : "default", fps : 1, loop : false, frames : sheet.map(["upgrade"]) }); // don't like this
				});
				
				Command.queueMany(
					ADD_TO(skillText, S2D, DEFAULT),
					ADD_TO(dmgText, S2D, DEFAULT),
					ADD_TO(critText, S2D, DEFAULT),
					ALLOC_SPRITE(ent, MAIN)
				);
				
				universe.setComponents(ent, anim);
				universe.setComponents(universe.createEntity(), skillInt);
				universe.setComponents(universe.createEntity(), dmgInt);
				universe.setComponents(universe.createEntity(), critInt);
				
			default:
		}
	}
}

@:structInit @:publicFields
private class DmgInstance {
	var time:Float;
	var damage:Int;
	var caster:Character;
}