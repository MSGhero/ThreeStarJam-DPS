package attacks;

import ecs.Entity;
import attacks.base.BaseAttack;

abstract Click(BaseAttack) from BaseAttack to BaseAttack {
	
	public function new(caster:Entity, level:AttackLevel, dmg:Int) {
		this = new BaseAttack(caster, level, DMG(dmg));
		this.updater.repetitions = 0; // don't start right away
		this.updater.duration = 0; // instantly apply when started
	}
}