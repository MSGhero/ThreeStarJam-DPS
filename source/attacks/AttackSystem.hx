package attacks;

import ecs.Entity;
import attacks.base.BaseBuff;
import attacks.base.BaseDebuff;
import attacks.base.BaseAttack;
import command.Command;
import ecs.Universe;
import ecs.System;
import haxe.ds.Vector;

class AttackSystem extends System {
	
	@:fastFamily
	var attackInfos : {
		attacks:Vector<BaseAttack>,
		buffs:Array<BaseBuff>,
		debuffs:Array<BaseDebuff>
	};
	
	public function new(ecs:Universe) {
		super(ecs);
		
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		Command.register(AttackCommand.UNLOCK(Entity.none, 0), handleAtkC);
		Command.register(AttackCommand.BUFF(Entity.none, null), handleAtkC); // params in the enum don't matter
		Command.register(AttackCommand.DEBUFF(Entity.none, null), handleAtkC);
	}
	
	function handleAtkC(atkc:AttackCommand) {
		
		switch (atkc) {
			case CLICK(char):
				fetch(attackInfos, char, {
					attacks[0].oneTime();
				});
			case UNLOCK(char, level):
				fetch(attackInfos, char, {
					attacks[level].enable();
				});
			case BUFF(caster, buff):
				switch (buff) {
					case CRIT:
						fetch(attackInfos, caster, {
							buffs.push(buff);
						});
				}
			case DEBUFF(caster, debuff):
				switch (debuff) {
					case DMG(amount):
						// this will get handled in dmgsys which deals w tracking over time
					case ATTACK(ba):
						ba.refreshReps();
						ba.enable();
				}
		}
	}
}