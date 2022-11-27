package attacks.base;

import timing.TimingCommand;
import ecs.Entity;
import command.Command;
import timing.Updater;

class BaseAttack {
	
	/**
		So the goal here is to set up repeating things
		Auto attack, damage over time ticks, occasional big hits, critical hits (on a random timer)
		To streamline things, everything is a buff or debuff
		Damage is a one-time debuff that immediately applies
		Crits apply a one-time buff that applies on the next attack
		The DoT cast itself is one attack on a certain timer, and the ticks are a debuff that applies another attack with limited repetitions
	**/
	
	public var buff(default, null):BaseBuff = null;
	public var debuff(default, null):BaseDebuff = null;
	
	public var updater(default, null):Updater;
	
	var caster:Entity;
	var savedReps:Int;
	
	public function new(caster:Entity, ?buff:BaseBuff, ?debuff:BaseDebuff) {
		
		updater = new Updater();
		updater.paused = true;
		updater.callback = apply;
		updater.autoDispose = false; // these will persist, so don't trash them when complete
		Command.queue(TimingCommand.ADD_UPDATER(caster, updater));
		
		this.caster = caster;
		this.buff = buff;
		this.debuff = debuff;
		
		savedReps = -1;
	}
	
	public inline function enable() {
		updater.paused = false; // all attacks are paused until unlocked
		@:privateAccess updater.counter = updater.duration; // we want a cast to immediately go off when acquired
	}
	
	public inline function disable() {
		updater.paused = true;
	}
	
	public inline function oneTime() {
		// for clicking
		updater.repetitions = 1;
	}
	
	public inline function saveReps() {
		savedReps = updater.repetitions;
	}
	
	public inline function refreshReps() {
		updater.repetitions = savedReps;
		updater.resetCounter();
	}
	
	function apply() {
		if (buff != null) Command.queue(AttackCommand.BUFF(caster, buff));
		if (debuff != null) Command.queue(AttackCommand.DEBUFF(caster, debuff)); 
	}
}