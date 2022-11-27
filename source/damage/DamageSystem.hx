package damage;

import timing.TimingCommand;
import timing.Updater;
import graphics.DisplayListCommand;
import hxd.res.DefaultFont;
import h2d.Text;
import characters.Character;
import haxe.ds.Vector;
import haxe.Timer;
import ecs.Entity;
import attacks.AttackCommand;
import command.Command;
import ecs.Universe;
import ecs.System;

class DamageSystem extends System {
	
	@:fastFamily
	var characters : {
		char:Character
	};
	
	// dps will be rolling average of 1 sec
	// track max damage
	// dps per or dps total? both
	// dps total prominently, dps per below char
	
	// record damage dealt at the end of each minute, per
	
	// data struct time
	
	// i don't think it makes too much sense putting any of this in ECS form
	// i also really don't want the entity count to have a chance of exploding when i could just use an array
	
	var rollingAvg:Array<DmgInstance>; // linked list prolly better here, but w/e
	var dps:Vector<Int>;
	var overallDPS:Int;
	
	var text:Text;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		rollingAvg = [];
		dps = new Vector(4);
		for (i in 0...dps.length) dps[i] = 0;
		overallDPS = 0;
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		Command.register(AttackCommand.DEBUFF(Entity.none, null), handleAtkC);
		Command.register(DisplayListCommand.PARENTS_SET_UP, handleDLC);
	}
	
	function handleAtkC(atkc:AttackCommand) {
		
		switch (atkc) {
			case DEBUFF(caster, DMG(amount)):
				
				fetch(characters, caster, {
					
					var di:DmgInstance = {
						time : Timer.stamp(),
						damage : amount,
						caster : char
					};
					
					rollingAvg.push(di);
				});
				
			default:
		}
	}
	
	function handleDLC(dlc:DisplayListCommand) {
		
		switch (dlc) {
			case PARENTS_SET_UP: // once all the setup in main is done for children to be added
				
				text = new Text(DefaultFont.get());
				text.textAlign = Left;
				text.x = 0; text.y = 0;
				
				var up = new Updater();
				up.duration = 0.25;
				up.repetitions = -1;
				up.callback = updateUI;
				
				Command.queueMany(
					DisplayListCommand.ADD_TO(text, S2D, DEFAULT),
					TimingCommand.ADD_UPDATER(universe.createEntity(), up)
				);
				
			default:
		}
	}
	
	function updateUI() {
		
		for (i in 0...dps.length) dps[i] = 0;
		
		if (rollingAvg.length > 0) {
			
			var t = Timer.stamp();
			
			while (rollingAvg.length > 0 && t - rollingAvg[0].time > 1) {
				rollingAvg.shift();
			}
			
			for (di in rollingAvg) {
				dps[di.caster] += di.damage;
			}
		}
		
		overallDPS = 0;
		for (i in 0...dps.length) overallDPS += dps[i];
		
		if (text != null) {
			text.text = 'Total DPS: $overallDPS\nWarrior DPS: ${dps[0]}\nMage DPS: ${dps[1]}';
		}
	}
}

@:structInit @:publicFields
private class DmgInstance {
	var time:Float;
	var damage:Int;
	var caster:Character;
}