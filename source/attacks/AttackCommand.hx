package attacks;

import attacks.AttackLevel;
import ecs.Entity;
import attacks.base.BaseDebuff;

enum AttackCommand {
	CLICK(char:Entity);
	UNLOCK(char:Entity, level:AttackLevel);
	DEBUFF(caster:Entity, debuff:BaseDebuff);
	LOG(caster:Entity, damage:Int, crit:Bool);
}