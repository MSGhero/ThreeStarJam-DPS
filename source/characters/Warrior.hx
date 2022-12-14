package characters;

import timing.TimingCommand;
import attacks.CritInfo;
import interactive.shapes.Circle;
import interactive.Interactive;
import attacks.Click;
import attacks.AttackCommand;
import command.Command;
import attacks.DoTCast;
import attacks.AutoDamage;
import attacks.base.BaseDebuff;
import attacks.AttackLevel;
import attacks.base.BaseAttack;
import haxe.ds.Vector;
import graphics.Spritesheet;
import graphics.Animation;
import ecs.Universe;
import characters.BaseChar;

@:transitive
abstract Warrior(BaseChar) to BaseChar {
	
	public function new(ecs:Universe, sheet:Spritesheet) {
		this = new BaseChar(ecs.createEntity());
		
		var anim = new Animation();
		anim.add({
			name : "attack",
			loop : false,
			fps : 12,
			frames : sheet.map(["axe_idle", "axe_windup", "axe_swing", "axe_swing", "axe_idle"]) // this isn't great, need ref to spritesheet here which I'm trying to avoid
			// maybe supply the strings and animsys creates the tile array? but then the sheet needs to be a compo or something
			// hmm
		})
		.add({
			name : "idle",
			loop : false,
			fps : 1,
			frames : sheet.map(["axe_idle"])
		})
		.add({
			name : "dot",
			loop : false,
			fps : 12,
			frames : sheet.map(["axe_idle", "axe_windup_dot", "axe_windup_dot", "axe_swing_dot", "axe_swing_dot", "axe_swing_dot", "axe_swing_dot", "axe_idle"])
		})
		.add({
			name : "adv",
			loop : false,
			fps : 6,
			frames : sheet.map(["axe_idle", "axe_pre_adv", "axe_cast_adv", "axe_cast_adv", "axe_flash_adv", "axe_cast_adv", "axe_cast_adv", "axe_idle"])
		})
		.add({
			name : "ult",
			loop : false,
			fps : 8,
			frames : sheet.map(["axe_idle", "axe_ult0", "axe_ult0", "axe_ult1", "axe_ult2", "axe_ult1", "axe_ult3", "axe_ult1", "axe_ult2", "axe_ult1", "axe_ult3", "axe_ult1", "axe_ult2", "axe_ult1", "axe_ult3", "axe_ult1", "axe_ult2", "axe_ult1", "axe_ult3", "axe_ult1", "axe_idle"])
		})
		;
		
		anim.play("idle");
		
		var attacks = new Vector<BaseAttack>(AttackLevel.ULT + 1);
		attacks[AttackLevel.BASIC] = new Click(this, BASIC, 2); // 2 per click
		attacks[AttackLevel.AUTO] = new AutoDamage(this, AUTO, 4, 1); // 4 per sec
		attacks[AttackLevel.DOT] = new DoTCast(this, DOT, 5, 3, 1.5, 5); // 3 per sec
		attacks[AttackLevel.ADV] = new AutoDamage(this, ADV, 100, 12.5); // 8 per sec
		attacks[AttackLevel.ULT] = new AutoDamage(this, ULT, 100, 10); // 10 per sec
		
		var debuffs:Array<BaseDebuff> = [];
		
		var critInfo = new CritInfo(0.25, 2);
		
		var int:Interactive = {
			shape : new Circle(464 - 22, 463 - 22, 60),
			enabled : true,
			onOver: () -> hxd.System.setCursor(Button),
			onOut: () -> hxd.System.setCursor(Default),
			onSelect: () -> Command.queue(CLICK(this))
		};
		
		ecs.setComponents(this, anim, attacks, debuffs, int, critInfo, 0xff96060d, Character.WARRIOR); // sprite already created
		Command.queueMany(
			UNLOCK(this, BASIC),
			ADD_UPDATER(this, critInfo.updater)
		);
	}
}