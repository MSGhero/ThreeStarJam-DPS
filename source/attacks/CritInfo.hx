package attacks;

import timing.TimingCommand;
import command.Command;
import timing.Updater;

class CritInfo {
	
	var chance:Float;
	var mult:Float;
	public var updater(default, null):Updater;
	
	public function new(chance:Float, mult:Float) {
		
		this.chance = chance;
		this.mult = mult;
		
		updater = new Updater();
		updater.duration = 5;
		updater.repetitions = 1;
		updater.autoDispose = false;
		updater.paused = true;
	}
	
	public function start() {
		updater.duration = 5;
		updater.repetitions = 1;
		updater.paused = false;
		updater.resetCounter();
	}
	
	public function getMultiplier() {
		if (updater.isActive && Math.random() <= chance) return mult;
		else return 1.0;
	}
}