package timing;

class Updater {
	
	public var duration:Float = 1; // setter, throw if <= 0. causes inf while loop
	public var repetitions:Int = -1;
	public var paused:Bool = false;
	public var autoDispose:Bool = true;
	public var changed(default, null):Bool = true;
	
	public var callback:()->Void = null;
	public var onComplete:()->Void = null;
	public var onCancel:()->Void = null;
	
	public var isActive(get, never):Bool;
	inline function get_isActive() { return !paused && repetitions != 0; }
	
	public var isTimeLeft(get, never):Bool;
	inline function get_isTimeLeft() { return counter > 0; }
	
	public var isReady(get, never):Bool;
	inline function get_isReady() { return counter >= duration; }
	
	var counter:Float = 0;
	var timescale:Float = 1.0;
	
	public function new() {
		
	}
	
	public function dispose() {
		callback = null;
		onComplete = null;
		onCancel = null;
	}
	
	public function cancel() {
		repetitions = 0;
		if (onCancel != null) onCancel();
	}
	
	public inline function resetCounter() {
		counter = 0;
		changed = true;
	}
	
	public function forceCallback() {
		
		if (callback != null) callback();
		
		if (repetitions > 0) {
			--repetitions;
			if (repetitions == 0 && onComplete != null) onComplete();
		}
		
		resetCounter();
	}
	
	public function forceComplete() {
		if (onComplete != null) onComplete();
		repetitions = 0;
		resetCounter();
	}
	
	public function update(dt:Float) {
		
		if (changed) changed = false;
		
		if (isActive) {
			
			while (isReady) {
				
				if (callback != null) callback();
				
				if (repetitions > 0) {
					--repetitions;
					if (repetitions == 0 && onComplete != null) onComplete();
				}
				
				if (duration <= 0) break; // avoid infinite while loops/allow for instant 0 duration calls
				else counter -= duration;
			}
			
			incrementCounter(dt);
		}
	}
	
	function incrementCounter(dt:Float) {
		counter += dt * timescale;
		changed = true;
	}
	
	function decrementCounter(dt:Float) {
		counter -= dt * timescale;
		changed = true;
	}
}