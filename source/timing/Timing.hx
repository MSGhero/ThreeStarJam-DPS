package timing;

import ecs.Entity;

class Timing {
	
	public static function every(dur:Float, reps:Int = -1, callback:() -> Void, onComplete:() -> Void = null) {
		
		var ev = new Updater();
		ev.duration = dur; ev.repetitions = reps;
		ev.callback = callback; ev.onComplete = onComplete;
		
		return ev;
	}
	
	public static function delay(dur:Float, onComplete:() -> Void) {
		
		var del = new Updater();
		del.duration = dur; del.repetitions = 1;
		del.onComplete = onComplete;
		
		return del;
	}
	
	// maybe make TweenerProps<T> that has from<T> to<T> dur onComplete ease, etc
	public static function tween(dur:Float, reps:Int = 1, onUpdate:(f:Float) -> Void, onComplete:() -> Void = null) {
		
		var tw = new Tweener(onUpdate);
		tw.duration = dur; tw.repetitions = reps;
		tw.onComplete = onComplete;
		
		return tw;
	}
	
	public static function cycle(updaters:UpdaterList, overallReps:Int = -1) {
		
		var cycle = new Cycler(updaters);
		cycle.repetitions = overallReps;
		
		return cycle;
	}
	
	public static function schedule(onComplete:() -> Void = null) {
		
		var scheduler = new Scheduler();
		scheduler.repetitions = 1;
		scheduler.onComplete = onComplete;
		
		return scheduler.init();
	}
	
	// cooldowner?
	// replenisher?
}