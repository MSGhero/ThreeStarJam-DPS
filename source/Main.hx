package;

import haxe.Timer;
import io.newgrounds.NG;
import audio.AudioVolume;
import hxd.snd.Manager;
import audio.AudioCommand;
import characters.Boss;
import characters.Dragoon;
import characters.Archer;
import damage.CritUI;
import damage.Hype;
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
import damage.UpgradeSystem;
import audio.AudioSystem;
import timing.Updater;
import utils.ResTools;

class Main extends App {
	
	var ecs:Universe;
	
	var updateLoop:Updater;
	var renderLoop:Updater;
	
	var updateFPS:Int = 60;
	var renderFPS:Int = 60;
	
	var updatePhase:Phase;
	
	var lastStamp:Float;
	
	var loadedIn:Bool;
	
	static function main() {
		#if !js
		Res.initPak();
		#end
		new Main();
	}
	
	override function init() {
		
		loadedIn = false; // some stuff is null at the beginning on JS
		@:privateAccess haxe.MainLoop.add(() -> {}); // bug that prevents sound from playing past 1 sec
		
		#if !js
		realInit();
		#else
		ResTools.initPakAuto("assets", () -> { // i need to write my own
			realInit();
		}, p -> { });
		#end
	}
	
	function realInit() {
		
		// ng login
		// login info is in pak file to obfuscate a bit
		var login = Res.data.login.entry.getText().split("\n");
		var appid = StringTools.trim(login[0]);
		var key = StringTools.trim(login[1]);
		
		NG.createAndCheckSession(appid);
		NG.core.setupEncryption(key);
		
		if (!NG.core.loggedIn) {
			NG.core.requestLogin(
				out -> {
					if (out.match(SUCCESS)) postLogin();
					else NG.core.onLogin.addOnce(postLogin);
				}
			);
		}
		
		engine.backgroundColor = 0xff888888;
		
		ecs = Universe.create({
			entities : 400,
			phases : [
				{
					name : "update",
					enabled : false,
					systems : [
						InputSystem,
						MouseSystem,
						AttackSystem,
						DamageSystem,
						UpgradeSystem,
						RenderSystem,
						AnimSystem,
						TimingSystem,
						InteractiveSystem,
						AudioSystem,
						CommandSystem // we usually want this to be the final system
					]
				}
			]
		});
		
		ecs.setResources(
			([]:Array<Command>), // command queue needs to be added before enabling everyone
			new Hype(), // hype meter
			Manager.get(), // sound manager
			({ music : 0.4 }:AudioVolume) // volume of different audio types
		);
		
		updatePhase = ecs.getPhase("update");
		updatePhase.enable();
		
		lastStamp = haxe.Timer.stamp();
		
		updateLoop = Timing.every(1 / updateFPS, onUpdate); // prepUpdate?
		
		renderLoop = Timing.every(1 / renderFPS, prepRender);
		s2d.setElapsedTime(1 / renderFPS);
		
		postInit();
	}
	
	function postInit() {
		
		loadedIn = true;
		
		var sheet = new Spritesheet();
		sheet.loadTexturePackerData(Res.sheets.sheet, Res.data.sheet.entry.getText(), "default");
		
		ecs.setResources(sheet);
		
		Command.queueMany(
			ADD_PARENT(s2d, S2D),
			ADD_SHEET(sheet, MAIN),
			CREATE_BATCH(MAIN, MAIN, S2D, S2D_GAME),
			PARENTS_SET_UP
		);
		
		// characters add themselves to the screen and appropriate families
		// this actually puts them below the background layer... since that is delayed due to the command
		var boss = new Boss(ecs, sheet);
		new Warrior(ecs, sheet);
		new Mage(ecs, sheet);
		new Archer(ecs, sheet);
		new Dragoon(ecs, sheet);
		
		var crits = ["axe_crit", "staff_crit", "spear_crit", "bow_crit"].map(s -> new CritUI(s, ecs, sheet));
		
		ecs.setResources(crits, boss);
		
		var input = new Input();
		var kmap = new InputMapping();
		kmap[Action.SELECT] = [Key.SPACE, Key.Z, Key.F, Key.ENTER];
		kmap[Action.MUTE] = [Key.M];
		input.addDevice(new KeyboardInput(kmap));
		var mmap = new InputMapping();
		mmap[Action.SELECT] = [Key.MOUSE_LEFT, Key.MOUSE_RIGHT];
		input.addDevice(new MouseInput(mmap));
		
		Command.queueMany(
			ADD_INPUT(input, P1),
			VISIBILITY(crits[0], false),
			VISIBILITY(crits[1], false),
			VISIBILITY(crits[2], false),
			VISIBILITY(crits[3], false),
			PLAY(MUSIC, "audio/music/1122420_Streambeat.ogg", true, 1, "")
		);
	}
	
	override function mainLoop() {
		
		var newTime = haxe.Timer.stamp();
		var dt = newTime - lastStamp;
		lastStamp = newTime;
		
		if (isDisposed || !loadedIn) return;
		
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
	
	function postLogin() {
		trace("logged in");
		NG.core.requestMedals(out2 -> {
			if (out2.match(SUCCESS)) {
				trace("got medals");
				ecs.setResources(NG.core); // add ng once loaded
			}
		});
	}
}
