package attacks;

import ecs.Entity;
import attacks.base.BaseAttack;

abstract AutoDamage(BaseAttack) to BaseAttack {
	
	public function new(caster:Entity, dmg:Int, tickDur:Float) {
		this = new BaseAttack(caster, ATTACK(new Damage(caster, dmg)));
		this.updater.duration = tickDur;
		this.updater.repetitions = -1;
	}
}