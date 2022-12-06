package damage;

import io.newgrounds.NG;
import api.APICommand;
import attacks.base.BaseAttack;
import graphics.Spritesheet;
import graphics.Animation;
import interactive.shapes.Circle;
import interactive.Interactive;
import attacks.CritInfo;
import graphics.DisplayListCommand;
import hxd.res.DefaultFont;
import h2d.Text;
import characters.Character;
import haxe.ds.Vector;
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
	
	@:fullFamily
	var api : {
		resources : {
			ng:NG
		}
	};
	
	var skillEnt:Entity;
	var dmgEnt:Entity;
	var critEnt:Entity;
	
	var skillText:Text;
	var dmgText:Text;
	var critText:Text;
	
	public function new(ecs:Universe) {
		super(ecs);
		
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		Command.register(PARENTS_SET_UP, handleDLC);
		Command.register(UNLOCK_MEDAL(0), handleAPIC);
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
				
				skillText = new Text(DefaultFont.get());
				skillText.textAlign = Center;
				skillText.textColor = 0xffffffff;
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
				
				dmgText = new Text(DefaultFont.get());
				dmgText.textAlign = Center;
				dmgText.textColor = 0xffffffff;
				dmgText.x = 168;
				dmgText.y = 406;
				
				// crit boost
				var critInt:Interactive = {
					shape : new Circle(297 - 22, 430 - 22, 60),
					enabled : true,
					onOver: () -> hxd.System.setCursor(Button),
					onOut: () -> hxd.System.setCursor(Default),
					onSelect: onCrit
				};
				
				critText = new Text(DefaultFont.get());
				critText.textAlign = Center;
				critText.textColor = 0xffffffff;
				critText.x = 272;
				critText.y = 458;
				
				updateText();
				
				var ent = universe.createEntity();
				skillEnt = universe.createEntity();
				dmgEnt = universe.createEntity();
				critEnt = universe.createEntity();
				
				var anim = new Animation();
				
				setup(characters, {
					anim.add({ name : "default", fps : 1, loop : false, frames : sheet.map(["bg"]) }); // don't like this
					anim.play("default");
				});
				
				Command.queueMany(
					ADD_TO(skillText, S2D, DEFAULT),
					ADD_TO(dmgText, S2D, DEFAULT),
					ADD_TO(critText, S2D, DEFAULT),
					ALLOC_SPRITE(ent, MAIN)
				);
				
				universe.setComponents(ent, anim);
				universe.setComponents(skillEnt, skillInt);
				universe.setComponents(dmgEnt, dmgInt);
				universe.setComponents(critEnt, critInt);
				
			default:
		}
	}
	
	function onSkill() {
		
		setup(characters, {
			
			if (hype.skill < hype.maxSkill && hype.value >= hype.skillCosts[hype.skill]) {
				
				hype.value -= hype.skillCosts[hype.skill];
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
					
					// all upgraded
					if (dmgEnt == Entity.none && critEnt == Entity.none) {
						Command.queue(UNLOCK_MEDAL(71857));
					}
				}
				
				updateText();
			}
		});
	}
	
	function onDmg() {
		
		setup(characters, {
			
			if (hype.dmgMult < hype.maxDmgMult && hype.value >= hype.dmgCosts[hype.dmgMult - 1]) {
				
				hype.value -= hype.dmgCosts[hype.dmgMult - 1];
				hype.dmgMult++;
				
				if (hype.dmgMult >= hype.maxDmgMult) {
					
					universe.deleteEntity(dmgEnt);
					dmgEnt = Entity.none;
					hxd.System.setCursor(Default);
					
					// all upgraded
					if (skillEnt == Entity.none && critEnt == Entity.none) {
						Command.queue(UNLOCK_MEDAL(71857));
					}
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
				
				updateText();
			}
		});
	}
	
	function onCrit() {
		
		setup(characters, {
			
			if (hype.critLevel < hype.maxCritLevel && hype.value >= hype.critCosts[hype.critLevel]) {
				
				hype.value -= hype.critCosts[hype.critLevel];
				hype.critLevel++;
				hype.critMult += 0.5;
				
				if (hype.critLevel >= hype.maxCritLevel) {
					
					hype.critMult = hype.maxCritMult;
					universe.deleteEntity(critEnt);
					critEnt = Entity.none;
					hxd.System.setCursor(Default);
					
					// all upgraded
					if (skillEnt == Entity.none && dmgEnt == Entity.none) {
						Command.queue(UNLOCK_MEDAL(71857));
					}
				}
				
				iterate(characters, {
					// bigger crits more often with less manual effort
					critInfo.mult = hype.critMult;
					critInfo.chance += 0.075;
					critInfo.updater.duration += 0.75;
				});
				
				updateText();
			}
		});
	}
	
	function updateText() {
		
		setup(characters, {
			skillText.text = hype.skill < hype.maxSkill ? 'New Skill\nHype cost: ${hype.skillCosts[hype.skill]}' : "4/4";
			dmgText.text = hype.dmgMult < hype.maxDmgMult ? 'More Damage\nHype cost: ${hype.dmgCosts[hype.dmgMult - 1]}' : "9/9";
			critText.text = hype.critLevel < hype.maxCritLevel ? 'Bigger Crits\nHype cost: ${hype.critCosts[hype.critLevel]}' : "6/6";
		});
	}
	
	function handleAPIC(apic:APICommand) {
		
		switch (apic) {
			case UNLOCK_MEDAL(id):
				setup(api, {
					var medal = ng.medals.getById(id);
					if (!medal.unlocked) {
						medal.sendUnlock();
						trace('got medal $id');
					}
				});
		}
	}
}

@:structInit @:publicFields
private class DmgInstance {
	var time:Float;
	var damage:Int;
	var caster:Character;
}
