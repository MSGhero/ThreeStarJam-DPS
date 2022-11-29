package attacks;

import timing.TimingCommand;
import command.Command;
import timing.Updater;

class CritInfo {
	
	public var chance:Float;
	public var mult:Float;
	public var updater(default, null):Updater;
	
	public function new(chance:Float, mult:Float) {
		
		this.chance = chance;
		this.mult = mult;
		
		updater = new Updater();
		updater.autoDispose = false;
		updater.paused = true;
		updater.duration = 3;
	}
	
	public function start() {
		updater.repetitions = 1;
		updater.paused = false;
		updater.resetCounter();
	}
	
	public function getChance() {
		if (updater.isActive) return chance;
		else return 0;
	}
}