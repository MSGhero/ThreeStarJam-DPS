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
abstract Archer(BaseChar) to BaseChar {
	
	public function new(ecs:Universe, sheet:Spritesheet) {
		this = new BaseChar(ecs.createEntity());
		
		var anim = new Animation();
		anim.add({
			name : "attack",
			loop : false,
			fps : 12,
			frames : sheet.map(["bow_idle", "bow_hold", "bow_hold", "bow_release", "bow_idle"])
		})
		.add({
			name : "idle",
			loop : false,
			fps : 1,
			frames : sheet.map(["bow_idle"])
		})
		.add({
			name : "dot",
			loop : false,
			fps : 12,
			frames : sheet.map(["bow_idle", "bow_hold_dot", "bow_hold_dot", "bow_hold_dot", "bow_hold_dot", "bow_release_dot", "bow_release_dot", "bow_idle"])
		})
		.add({
			name : "adv",
			loop : false,
			fps : 6,
			frames : sheet.map(["bow_idle", "bow_pre_adv", "bow_cast_adv", "bow_cast_adv", "bow_flash_adv", "bow_cast_adv", "bow_cast_adv", "bow_idle"])
		})
		.add({
			name : "ult",
			loop : false,
			fps : 6,
			frames : sheet.map(["bow_idle", "bow_ult0", "bow_ult1", "bow_ult2", "bow_ult3", "bow_ult4", "bow_ult5", "bow_ult5", "bow_ult5", "bow_ult5", "bow_ult6", "bow_ult7", "bow_idle"])
		})
		;
		
		anim.play("idle");
		
		var attacks = new Vector<BaseAttack>(AttackLevel.ULT + 1);
		attacks[AttackLevel.BASIC] = new Click(this, BASIC, 2); // 2 per click
		attacks[AttackLevel.AUTO] = new AutoDamage(this, AUTO, 2, 0.5); // 4 per sec
		attacks[AttackLevel.DOT] = new DoTCast(this, DOT, 5, 6, 1, 10); // 3 per sec
		attacks[AttackLevel.ADV] = new AutoDamage(this, ADV, 120, 15); // 8 per sec
		attacks[AttackLevel.ULT] = new AutoDamage(this, ULT, 200, 20); // 10 per sec
		
		var debuffs:Array<BaseDebuff> = [];
		
		var int:Interactive = {
			shape : new Circle(853 - 22, 137 - 22, 60),
			enabled : true,
			onOver: () -> hxd.System.setCursor(Button),
			onOut: () -> hxd.System.setCursor(Default),
			onSelect: () -> Command.queue(CLICK(this))
		};
		
		var critInfo = new CritInfo(0.25, 2);
		
		ecs.setComponents(this, anim, attacks, debuffs, int, critInfo, 0xff37d98c, Character.ARCHER); // sprite already created
		Command.queueMany(
			UNLOCK(this, BASIC),
			ADD_UPDATER(this, critInfo.updater)
		);
	}
}