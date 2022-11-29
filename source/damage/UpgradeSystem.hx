package damage;

import attacks.base.BaseAttack;
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
			attacks:Vector<BaseAttack>,
			char:Character,
			color:Int,
			critInfo:CritInfo
		}
	};
	
	var skillEnt:Entity;
	var dmgEnt:Entity;
	var critEnt:Entity;
	
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
					onSelect: onSkill
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
					onSelect: onDmg
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
					onSelect: onCrit
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
				universe.setComponents(skillEnt = universe.createEntity(), skillInt);
				universe.setComponents(dmgEnt = universe.createEntity(), dmgInt);
				universe.setComponents(critEnt = universe.createEntity(), critInt);
				
			default:
		}
	}
	
	function onSkill() {
		
		setup(characters, {
			
			// add cost
			if (hype.skill < hype.maxSkill) {
				
				hype.skill++;
				
				iterate(characters, entity -> {
					Command.queueMany(
						UNLOCK(entity, hype.skill)
					);
				});
				
				if (hype.skill >= hype.maxSkill) {
					universe.deleteEntity(skillEnt);
					skillEnt = Entity.none;
					hxd.System.setCursor(Default);
				}
			}
		});
	}
	
	function onDmg() {
		
		setup(characters, {
			
			// add cost
			if (hype.dmgMult < hype.maxDmgMult) {
				
				hype.dmgMult++;
				
				if (hype.dmgMult >= hype.maxDmgMult) {
					universe.deleteEntity(dmgEnt);
					dmgEnt = Entity.none;
					hxd.System.setCursor(Default);
				}
				
				iterate(characters, {
					
					var prevFactor = (1 - 1 / 36 * (hype.dmgMult - 1)); // speed up attacks a little
					var factor = (1 - 1 / 36 * hype.dmgMult); // kinda messes with the animations going too fast, so don't do that lol
					
					for (atk in attacks) {
						atk.updater.duration *= factor / prevFactor;
						switch (atk.debuff) {
							case ATTACK(ba): ba.updater.duration *= factor / prevFactor; // speed up dot as well
							default:
						}
					}
				});
			}
		});
	}
	
	function onCrit() {
		
		setup(characters, {
			
			if (hype.critMult < hype.maxCritMult) {
				
				hype.critMult += 0.5;
				
				if (hype.critMult >= hype.maxCritMult) {
					hype.critMult = hype.maxCritMult;
					universe.deleteEntity(critEnt);
					critEnt = Entity.none;
					hxd.System.setCursor(Default);
				}
				
				iterate(characters, {
					// bigger crits more often with less manual effort
					critInfo.mult = hype.critMult;
					critInfo.chance += 0.075;
					critInfo.updater.duration += 0.5;
				});
			}
		});
	}
}

@:structInit @:publicFields
private class DmgInstance {
	var time:Float;
	var damage:Int;
	var caster:Character;
}