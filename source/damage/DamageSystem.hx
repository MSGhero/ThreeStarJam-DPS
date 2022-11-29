package damage;

import h2d.Font;
import attacks.CritInfo;
import graphics.Sprite;
import timing.Tweener;
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
	
	@:fullFamily
	var characters : {
		resources : {
			hype:Hype
		},
		requires : {
			char:Character,
			color:Int,
			critInfo:CritInfo
		}
	};
	
	@:fullFamily
	var sprites : {
		resources : {
			critUIs:Array<CritUI>
		},
		requires : {
			sprite:Sprite
		}
	};
	
	var rollingAvg:Array<DmgInstance>; // linked list prolly better here, but w/e
	var dps:Vector<Float>;
	var maxAvg:Float;
	var maxDPS:Vector<Float>;
	
	var dmgFont:Font;
	var text:Text;
	var hypeText:Text;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		rollingAvg = [];
		maxAvg = 0;
		
		dps = new Vector(4);
		maxDPS = new Vector(4);
		for (i in 0...dps.length) dps[i] = maxDPS[i] = 0;
		
		dmgFont = DefaultFont.get().clone();
		dmgFont.resizeTo(24);
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		Command.register(LOG(Entity.none, 0, false), handleAtkC);
		Command.register(CLICK(Entity.none), handleAtkC);
		Command.register(PARENTS_SET_UP, handleDLC);
	}
	
	function handleAtkC(atkc:AttackCommand) {
		
		switch (atkc) {
			case CLICK(chara):
				setup(sprites, {
					fetch(characters, chara, {
						var ent = critUIs[char];
						
						fetch(sprites, ent, {
							sprite.visible = true;
							critInfo.updater.onComplete = () -> sprite.visible = false;
						});
					});
				});
				
			case LOG(caster, amount, crit):
				
				setup(characters, {
					fetch(characters, caster, {
						
						var di:DmgInstance = {
							time : Timer.stamp(),
							damage : amount,
							caster : char
						};
						
						rollingAvg.push(di);
						hype.value += amount / 10;
					});
				});
				
				showDamage(caster, amount, crit);
				
			default:
		}
	}
	
	function handleDLC(dlc:DisplayListCommand) {
		
		switch (dlc) {
			case PARENTS_SET_UP: // once all the setup in main is done for children to be added
				
				text = new Text(DefaultFont.get());
				text.textAlign = Left;
				text.textColor = 0xffffffff;
				text.x = 15; text.y = 15;
				
				hypeText = new Text(dmgFont);
				hypeText.textAlign = Left;
				hypeText.textColor = 0xffffffff;
				hypeText.x = 15; hypeText.y = 325;
				
				var up = new Updater();
				up.duration = 0.25;
				up.repetitions = -1;
				up.callback = updateUI;
				
				Command.queueMany(
					ADD_TO(text, S2D, DEFAULT),
					ADD_TO(hypeText, S2D, DEFAULT),
					ADD_UPDATER(universe.createEntity(), up)
				);
				
			default:
		}
	}
	
	function updateUI() {
		
		setup(characters, {
			
			final t = Timer.stamp();
			final h = hype.value;
			
			final overallDPS = setUpDPS(rollingAvg, dps, 1, t);
			
			if (overallDPS > maxAvg) maxAvg = overallDPS;
			
			for (i in 0...dps.length) {
				if (dps[i] > maxDPS[i]) maxDPS[i] = dps[i];
			}
			
			if (text != null) {
				text.text = 'Total DPS (Max): ${formatDPS(overallDPS, 0)} (${formatDPS(maxAvg, 1)})' +
					'\nWarrior DPS: ${formatDPS(dps[0], 0)} (${formatDPS(maxDPS[0], 1)})' +
					'\nMage DPS: ${formatDPS(dps[1], 0)} (${formatDPS(maxDPS[1], 1)})' +
					'\nDragoon DPS: ${formatDPS(dps[2], 0)} (${formatDPS(maxDPS[2], 1)})' +
					'\nArcher DPS: ${formatDPS(dps[3], 0)} (${formatDPS(maxDPS[3], 1)})'
				;
			}
			
			if (hypeText != null) {
				hypeText.text = 'Hype: ${formatDPS(h, h < 10 ? 2 : h < 100 ? 1 : 0)}'; // show decimals of hype only when relevant
			}
		});
	}
	
	function setUpDPS(dmgList:Array<DmgInstance>, dpsList:Vector<Float>, duration:Float, time:Float) {
		
		for (i in 0...dpsList.length) dpsList[i] = 0;
		
		if (dmgList.length > 0) {
			
			while (dmgList.length > 0 && time - dmgList[0].time > duration) {
				dmgList.shift();
			}
			
			for (di in dmgList) {
				dpsList[di.caster] += di.damage / duration;
			}
		}
		
		var overallDPS = 0.0;
		for (i in 0...dpsList.length) overallDPS += dpsList[i];
		
		return overallDPS;
	}
	
	function formatDPS(dps:Float, decimals:Int) {
		final zeroes = Math.pow(10, decimals);
		final temp = Math.floor(dps * zeroes);
		return temp / zeroes;
	}
	
	function showDamage(caster:Entity, damage:Int, crit:Bool) {
		
		var ent = universe.createEntity();
		
		var text = new Text(dmgFont);
		text.x = Math.random() * 180 + 75;
		text.y = 180 - Math.random() * 20;
		text.textAlign = Center;
		text.text = Std.string(damage);
		
		var y = text.y;
		
		if (crit) {
			fetch(characters, caster, {
				text.textColor = color;
			});
		}
		
		else {
			text.textColor = 0xffffffff;
		}
		
		var tw = new Tweener(f -> {
			text.alpha = 1 - f * f;
			text.y = y - 75 * f;
		});
		
		tw.duration = 0.75;
		tw.repetitions = 1;
		tw.onComplete = () -> {
			Command.queue(REMOVE_FROM_PARENT(text)); // hope this doesn't cause memory leaks lol. better to tie to entity eventually
			universe.deleteEntity(ent);
		};
		
		Command.queueMany(
			ADD_TO(text, S2D, DEFAULT),
			ADD_UPDATER(ent, tw)
		);
	}
}

@:structInit @:publicFields
private class DmgInstance {
	var time:Float;
	var damage:Int;
	var caster:Character;
}