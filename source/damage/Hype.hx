package damage;

import attacks.AttackLevel;

class Hype {
	
	public var value:Float;
	
	public var skill:Int;
	public var maxSkill:Int;
	public var skillCosts:Array<Int>;
	
	public var dmgMult:Int; // better for a diff variable to start at 0, for indexing
	public var maxDmgMult:Int;
	public var dmgCosts:Array<Int>;
	
	public var critLevel:Int; // to track outside of the float values
	public var maxCritLevel:Int; // i added these later, kinda redundant oh well
	public var critMult:Float;
	public var maxCritMult:Float;
	public var critCosts:Array<Int>;
	
	public function new() {
		
		value = 0;
		
		skill = 0;
		maxSkill = AttackLevel.ULT;
		
		dmgMult = 1;
		maxDmgMult = 10;
		
		critLevel = 0;
		maxCritLevel = 6;
		critMult = 2;
		maxCritMult = 5;
		
		skillCosts = [20, 200, 2000, 5000];
		dmgCosts = [10, 25, 50, 100, 400, 900, 2500, 5000, 30000];
		critCosts = [25, 200, 600, 2000, 4500, 24000];
	}
}