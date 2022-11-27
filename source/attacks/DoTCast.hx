package attacks;

import ecs.Entity;
import attacks.DotTick.DoTTick;
import attacks.base.BaseAttack;

abstract DoTCast(BaseAttack) to BaseAttack {
	
	public function new(caster:Entity, dmg:Int, ticks:Int, tickDur:Float, totalDur:Float) {
		this = new BaseAttack(caster, ATTACK(new DoTTick(caster, dmg, ticks, tickDur))); // give DoT debuff which actually does damage
		this.updater.duration = totalDur; // recast DoT every totalDur
		this.updater.repetitions = -1;
	}
}