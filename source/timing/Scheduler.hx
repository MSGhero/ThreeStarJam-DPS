package timing;

class Scheduler extends Updater {
	
	// reconsider handling
	
	// aos isntead of soa?
	var updaters:Array<Updater> = [];
	var cleanup:Array<Bool> = [];
	var completes:Array<() -> Void> = [];
	var cancels:Array<() -> Void> = [];
	var index:Int = 0;
	
	var latest(get, never):Updater;
	inline function get_latest() { return updaters[updaters.length - 1]; }
	
	public function new() {
		super();
		
	}
	
	function advance() {
		
		++index;
		
		if (index < updaters.length) {
			
			if (cleanup[index]) { // internally created, do whatever
				latest.paused = false;
			}
			
			// else, created externally and shouldn't modify
			// assume it is set up well and will converge
			// not affected by excess dt since it could be doing something completely different
		}
	}
	
	public inline function init() {
		return (this:CompleteInitial);
	}
	
	public function first(complete:() -> Void) {
		
		updaters.push(getNullUpdater());
		cleanup.push(true);
		completes.push(complete);
		cancels.push(null);
		
		return (this:CompleteFirst);
	}
	
	public function then(onComplete:() -> Void) {
		
		if (completes.length == 0) first(onComplete);
		
		else if (completes[completes.length - 1] != null) {
			
			updaters.push(getNullUpdater());
			cleanup.push(true);
			completes.push(onComplete);
			cancels.push(null);
		}
		
		else completes[completes.length - 1] = onComplete;
		
		return (this:CompleteThen);
	}
	
	public function ifCancelled(onCancel:() -> Void) {
		cancels[cancels.length - 1] = onCancel;
		return this;
	}
	
	public function thenWait(dur:Float) {
		
		var up = getNullUpdater();
		up.duration = dur; up.repetitions = 1;
		
		updaters.push(up);
		cleanup.push(true);
		completes.push(null);
		cancels.push(null);
		
		return (this:CompleteWait);
	}
	
	public function thenIterate(dur:Float, reps:Int, callback:() -> Void) {
		
		var up = getNullUpdater();
		up.duration = dur; up.repetitions = reps;
		up.callback = callback;
		
		updaters.push(up);
		cleanup.push(true);
		completes.push(null);
		cancels.push(null);
		
		return (this:CompleteIterate);
	}
	
	public function thenComplete(updater:Updater, externallyUpdated:Bool = true) {
		
		updaters.push(updater);
		cleanup.push(!externallyUpdated);
		completes.push(null);
		cancels.push(null);
		
		return (this:CompleteExternal);
	}
	
	public function thenTween(dur:Float, onUpdate:(easedPerc:Float) -> Void) {
		
		var tw = new Tweener(onUpdate);
		tw.duration = dur; tw.repetitions = 1;
		
		updaters.push(tw);
		cleanup.push(true);
		completes.push(null);
		cancels.push(null);
		
		return (this:CompleteTween);
	}
	
	public function thenBranch(updaters:UpdaterList) {
		
		var par = new Paralleler(updaters);
		par.repetitions = 1;
		
		this.updaters.push(par);
		cleanup.push(true);
		completes.push(null);
		cancels.push(null);
		
		return (this:CompleteBranch);
	}
	
	override function dispose() {
		
		if (updaters != null) {
			for (i in 0...updaters.length)
				if (cleanup[i])
					updaters[i].dispose();
			
			updaters = null;
			cleanup = null;
			completes = null;
			cancels = null;
		}
		
		super.dispose();
	}
	
	override function cancel() {
		cancelAll();
		super.cancel();
	}
	
	public function cancelCurrent() {
		
		if (updaters != null && index < updaters.length) {
			updaters[index].repetitions = 0;
			if (cancels != null && cancels[index] != null) cancels[index]();
		}
	}
	
	function cancelAll() {
		
		while (index < updaters.length) {
			cancelCurrent();
			index++;
		}
	}
	
	function checkAdvance() {
		// while handles multiple calls in a row with 0 reps left
		while (index < updaters.length && updaters[index].repetitions == 0 && repetitions > 0) {
			
			// just completed, move on
			if (completes[index] != null) completes[index]();
			
			// this actually breaks, not sure if count up vs down issue
			// but large times are left on counter in some cases, which wrecks iterate and short duration things
			// var f = updaters[index].counter; // residual dt should be passed onto next updater (if internal)
			advance();
			
			if (index < updaters.length) {
				// if (cleanup[index]) updaters[index].counter = f;
			}
			
			else {
				repetitions = 0;
				if (onComplete != null) onComplete();
			}
		}
	}
	
	function getNullUpdater() {
		// somewhere more centralized maybe?
		var up = new Updater();
		up.counter = 1; up.duration = 1; // forces immediate callback
		up.repetitions = 0;
		up.onComplete = null;
		
		return up;
	}
	
	override function update(dt:Float) {
		
		if (isActive && index < updaters.length) {
			checkAdvance(); // mainly for first()
		}
		
		if (isActive && index < updaters.length) {
			// external updaters are handling themselves, if set that way
			// if so, the timing relative to this call may need to be considered
			if (cleanup[index]) updaters[index].update(dt);
			
			checkAdvance();
		}
	}
}

@:forward(then, thenWait, thenIterate, thenComplete, thenTween, thenBranch, first)
private abstract CompleteInitial(Scheduler) from Scheduler to Scheduler { }

@:forward(then, thenWait, ifCancelled, thenIterate, thenComplete, thenTween, thenBranch)
private abstract CompleteFirst(Scheduler) from Scheduler to Scheduler { }
private typedef CompleteThen = CompleteFirst;
private typedef CompleteWait = CompleteFirst;
private typedef CompleteExternal = CompleteFirst;
private typedef CompleteIterate = CompleteFirst;
private typedef CompleteTween = CompleteFirst;

private abstract CompleteBranch(Scheduler) from Scheduler to Scheduler { }