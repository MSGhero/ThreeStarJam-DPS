package damage;

import attacks.AttackLevel;

class Hype {
	
	public var value:Float;
	
	public var skill:Int;
	public var maxSkill:Int;
	
	public var dmgMult:Int;
	public var maxDmgMult:Int;
	
	public function new() {
		
		value = 0;
		
		skill = 0;
		maxSkill = AttackLevel.ULT;
		
		dmgMult = 1;
		maxDmgMult = 10;
	}
}