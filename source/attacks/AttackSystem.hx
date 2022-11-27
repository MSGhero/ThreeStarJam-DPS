package attacks;

import ecs.Entity;
import attacks.base.BaseDebuff;
import attacks.base.BaseAttack;
import command.Command;
import ecs.Universe;
import ecs.System;
import haxe.ds.Vector;
import attacks.AttackCommand;

class AttackSystem extends System {
	
	@:fastFamily
	var attackInfos : {
		attacks:Vector<BaseAttack>,
		debuffs:Array<BaseDebuff>,
		critInfo:CritInfo
	};
	
	public function new(ecs:Universe) {
		super(ecs);
		
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
			case UNLOCK(char, level):
				fetch(attackInfos, char, {
					attacks[level].enable();
				});
			case DEBUFF(caster, debuff):
				switch (debuff) {
					case DMG(amount):
						
						var total = amount;
						var crit = false;
						
						fetch(attackInfos, caster, {
							
							if (Math.random() < critInfo.getChance()) {
								total = Std.int(total * critInfo.mult);
								crit = true;
							}
						});
						
						Command.queue(LOG(caster, total, crit));
						
					case ATTACK(ba):
						ba.refreshReps();
						ba.enable();
				}
			default:
		}
	}
}