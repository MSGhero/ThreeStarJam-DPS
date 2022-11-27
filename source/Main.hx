package;

import characters.Mage;
import input.KeyboardInput;
import characters.Warrior;
import interactive.Interactive;
import input.MouseInput;
import input.InputCommand;
import hxd.Key;
import input.Action;
import input.Input;
import graphics.DisplayListCommand;
import graphics.RenderCommand;
import command.Command;
import graphics.Animation;
import graphics.Spritesheet;
import graphics.Sprite;
import timing.Timing;
import ecs.Universe;
import ecs.Phase;
import hxd.Res;
import hxd.App;
import graphics.AnimSystem;
import graphics.RenderSystem;
import command.CommandSystem;
import timing.TimingSystem;
import input.InputSystem;
import input.MouseSystem;
import interactive.InteractiveSystem;
import attacks.AttackSystem;
import damage.DamageSystem;
import timing.Updater;

class Main extends App {
	
	var ecs:Universe;
	
	var updateLoop:Updater;
	var renderLoop:Updater;
	
	var updateFPS:Int = 60;
	var renderFPS:Int = 60;
	
	var updatePhase:Phase;
	
	var lastStamp:Float;
	
	static function main() {
		Res.initEmbed();
		new Main();
	}
	
	// need realinit for when assets need to load
	
	override function init() {
		
		engine.backgroundColor = 0xff888888;
		
		ecs = Universe.create({
			entities : 200,
			phases : [
				{
					name : "update",
					enabled : false,
					systems : [
						InputSystem,
						MouseSystem,
						AttackSystem,
						DamageSystem,
						RenderSystem,
						AnimSystem,
						TimingSystem,
						InteractiveSystem,
						CommandSystem // we usually want this to be the final system
					]
				}
			]
		});
		
		ecs.setResources(([]:Array<Command>)); // command queue needs to be added before enabling everyone
		
		updatePhase = ecs.getPhase("update");
		// this requires some mods to the ECS lib that won't get approved for merge. i need to work on a better solution still
		updatePhase.enableSystems(); // enable in post so commandsys can set itself up before onEnabled()s
		updatePhase.enable();
		
		lastStamp = haxe.Timer.stamp();
		
		updateLoop = Timing.every(1 / updateFPS, onUpdate); // prepUpdate?
		
		renderLoop = Timing.every(1 / renderFPS, prepRender);
		s2d.setElapsedTime(1 / renderFPS);
		
		postInit();
	}
	
	function postInit() {
		
		var sheet = new Spritesheet();
		sheet.loadTexturePackerData(Res.images.sheet, Res.data.sheet.entry.getText(), "default");
		
		Command.queueMany(
			DisplayListCommand.ADD_PARENT(s2d, S2D),
			RenderCommand.ADD_SHEET(sheet, MAIN),
			RenderCommand.CREATE_BATCH(MAIN, MAIN, S2D, S2D_GAME),
			DisplayListCommand.PARENTS_SET_UP
		);
		
		var warrior = new Warrior(ecs, sheet);
		var mage = new Mage(ecs, sheet);
		
		var input = new Input();
		var kmap = new InputMapping();
		kmap[Action.SELECT] = [Key.SPACE, Key.Z, Key.F, Key.ENTER];
		input.addDevice(new KeyboardInput(kmap));
		var mmap = new InputMapping();
		mmap[Action.SELECT] = [Key.MOUSE_LEFT, Key.MOUSE_RIGHT];
		input.addDevice(new MouseInput(mmap));
		
		Command.queue(InputCommand.ADD_INPUT(input, P1));
	}
	
	override function mainLoop() {
		
		var newTime = haxe.Timer.stamp();
		var dt = newTime - lastStamp;
		lastStamp = newTime;
		
		if (isDisposed) return;
		
		update(dt);
	}
	
	override function update(dt:Float) {
		
		hxd.Timer.update();
		
		updateLoop.update(dt); // game logic
		renderLoop.update(dt); // render
	}
	
	function onFrame() { }
	
	function onUpdate() {
		// pre post prep?
		sevents.checkEvents();
		updatePhase.update(1 / updateFPS);
	}
	
	function prepRender() {
		
		if (!engine.begin()) return;
		
		onRender();
		engine.end();
	}
	
	function onRender() {
		
		s2d.render(engine);
		
		// trace("draw calls: " + engine.drawCalls);
	}
}