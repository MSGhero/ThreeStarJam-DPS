package damage;

import attacks.AttackLevel;

class Hype {
	
	public var value:Float;
	
	public var skill:Int;
	public var maxSkill:Int;
	
	public var dmgMult:Int;
	public var maxDmgMult:Int;
	
	public var critMult:Float;
	public var maxCritMult:Float;
	
	public function new() {
		
		value = 0;
		
		skill = 0;
		maxSkill = AttackLevel.ULT;
		
		dmgMult = 1;
		maxDmgMult = 10;
		
		critMult = 2;
		maxCritMult = 5;
	}
}