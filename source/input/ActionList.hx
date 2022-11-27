package input;

import haxe.ds.Vector;

@:forward @:build(input.ActionMacros.buildInput(Action))
abstract ActionList(Vector<Bool>) {
	
	public function new() {
		this = new Vector(ActionMacros.count(Action));
		for (i in 0...this.length) this[i] = false;
	}

	public function copyFrom(al:ActionList) {
		
		for (i in 0...this.length) {
			this[i] = al[i];
		}
	}
	
	@:op([])
	public inline function get(index:Int) {
		return this.get(index);
	}
	
	@:op([])
	public inline function set(index:Int, val:Bool) {
		return this.set(index, val);
	}
}