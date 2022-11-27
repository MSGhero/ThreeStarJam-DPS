package attacks;

import ecs.Entity;
import attacks.base.BaseAttack;

abstract Damage(BaseAttack) to BaseAttack {
	
	public function new(caster:Entity, level:AttackLevel, dmg:Int) {
		this = new BaseAttack(caster, level, DMG(dmg));
		this.updater.duration = 0; // instantly apply
		this.updater.repetitions = 1; // once
		this.saveReps();
	}
}