package attacks;

import ecs.Entity;
import attacks.base.BaseAttack;

abstract AutoDamage(BaseAttack) to BaseAttack {
	
	public function new(caster:Entity, level:AttackLevel, dmg:Int, tickDur:Float) {
		this = new BaseAttack(caster, level, ATTACK(new Damage(caster, level, dmg)));
		this.updater.duration = tickDur;
		this.updater.repetitions = -1;
	}
}