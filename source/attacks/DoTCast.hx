package attacks;

import ecs.Entity;
import attacks.DotTick.DoTTick;
import attacks.base.BaseAttack;

abstract DoTCast(BaseAttack) to BaseAttack {
	
	public function new(caster:Entity, level:AttackLevel, dmg:Int, ticks:Int, tickDur:Float, totalDur:Float) {
		this = new BaseAttack(caster, level, ATTACK(new DoTTick(caster, level, dmg, ticks, tickDur))); // give DoT debuff which actually does damage
		this.updater.duration = totalDur; // recast DoT every totalDur
		this.updater.repetitions = -1;
	}
}