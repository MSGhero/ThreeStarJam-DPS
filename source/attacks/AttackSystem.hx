package attacks;

import characters.Boss;
import damage.Hype;
import graphics.Animation;
import ecs.Entity;
import attacks.base.BaseDebuff;
import attacks.base.BaseAttack;
import command.Command;
import ecs.Universe;
import ecs.System;
import haxe.ds.Vector;
import attacks.AttackCommand;

class AttackSystem extends System {
	
	@:fullFamily
	var attackInfos : {
		resources : {
			hype:Hype,
			boss:Boss
		},
		requires : {
			attacks:Vector<BaseAttack>,
			debuffs:Array<BaseDebuff>,
			critInfo:CritInfo
		}
	};
	
	@:fastFamily
	var anims : {
		anim:Animation
	}
	
	var animPrio:Array<String>;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		animPrio = ["attack", "attack", "dot", "adv", "ult"];
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		Command.register(CLICK(Entity.none), handleAtkC);
		Command.register(UNLOCK(Entity.none, 0), handleAtkC);
		Command.register(DEBUFF(Entity.none, null), handleAtkC);
	}
	
	function handleAtkC(atkc:AttackCommand) {
		
		switch (atkc) {
			case CLICK(char):
				
				fetch(attackInfos, char, {
					attacks[0].oneTime();
					critInfo.start();
				});
				
				fetch(anims, char, {
					if (!anim.isActive) { // shouldn't override anything, so no need to check for higher prio anims
						anim.play("attack");
					}
				});
				
				setup(attackInfos, {
					fetch(anims, boss, {
						if (!anim.isActive) {
							anim.play(Math.random() < 0.5 ? "def_hard" : "def_soft");
						}
					});
				});
				
			case UNLOCK(char, level):
				fetch(attackInfos, char, {
					attacks[level].enable();
				});
			case DEBUFF(caster, debuff):
				switch (debuff) {
					case DMG(amount):
						
						setup(attackInfos, {
							
							var total = amount * hype.dmgMult;
							var crit = false;
							
							fetch(attackInfos, caster, {
								
								if (Math.random() < critInfo.getChance()) {
									total = Std.int(total * critInfo.mult);
									crit = true;
								}
							});
							
							fetch(anims, boss, {
								if (!anim.isActive) {
									anim.play(Math.random() < 0.5 ? "def_hard" : "def_soft");
								}
							});
							
							Command.queue(LOG(caster, total, crit));
						});
						
					case ATTACK(ba):
						
						ba.refreshReps();
						ba.enable();
						
						fetch(anims, caster, {
							if (!anim.isActive || (ba.level:Int) > animPrio.indexOf(anim.name)) {
								anim.play(animPrio[ba.level]); // diff anims for diff attacks?
							}
						});
				}
			default:
		}
	}
}