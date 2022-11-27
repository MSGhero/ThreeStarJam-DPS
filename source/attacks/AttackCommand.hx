package attacks;

import attacks.AttackLevel;
import ecs.Entity;
import attacks.base.BaseDebuff;
import attacks.base.BaseBuff;

enum AttackCommand {
	CLICK(char:Entity);
	UNLOCK(char:Entity, level:AttackLevel); // maybe not entity here
	BUFF(caster:Entity, buff:BaseBuff);
	DEBUFF(caster:Entity, debuff:BaseDebuff);
}