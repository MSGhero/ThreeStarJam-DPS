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
abstract Dragoon(BaseChar) to BaseChar {
	
	public function new(ecs:Universe, sheet:Spritesheet) {
		this = new BaseChar(ecs.createEntity());
		
		var anim = new Animation();
		anim.add({
			name : "attack",
			loop : false,
			fps : 12,
			frames : sheet.map(["spear_idle", "spear_pre", "spear_thrust", "spear_thrust", "spear_idle"])
		})
		.add({
			name : "idle",
			loop : false,
			fps : 1,
			frames : sheet.map(["spear_idle"])
		})
		.add({
			name : "dot",
			loop : false,
			fps : 12,
			frames : sheet.map(["spear_idle", "spear_pre_dot", "spear_pre_dot", "spear_thrust_dot", "spear_thrust_dot", "spear_thrust_dot", "spear_thrust_dot", "spear_idle"])
		})
		.add({
			name : "adv",
			loop : false,
			fps : 6,
			frames : sheet.map(["spear_idle", "spear_pre_adv", "spear_cast_adv", "spear_cast_adv", "spear_flash_adv", "spear_cast_adv", "spear_cast_adv", "spear_idle"])
		})
		.add({
			name : "ult",
			loop : false,
			fps : 16,
			frames : sheet.map(["spear_idle", "spear_ult0", "spear_ult0", "spear_ult1", "spear_ult2", "spear_ult3", "spear_ult3", "spear_ult3", "spear_ult3", "spear_ult3", "spear_ult3", "spear_ult3", "spear_ult3", "spear_ult3", "spear_ult4", "spear_ult5", "spear_ult6", "spear_ult6", "spear_ult6", "spear_ult6", "spear_ult6", "spear_ult7", "spear_ult7", "spear_idle"])
		})
		;
		
		anim.play("idle");
		
		var attacks = new Vector<BaseAttack>(AttackLevel.ULT + 1);
		attacks[AttackLevel.BASIC] = new Click(this, BASIC, 2); // 2 per click
		attacks[AttackLevel.AUTO] = new AutoDamage(this, AUTO, 4, 1); // 4 per sec
		attacks[AttackLevel.DOT] = new DoTCast(this, DOT, 5, 9, 0.5, 15); // 3 per sec
		attacks[AttackLevel.ADV] = new AutoDamage(this, ADV, 160, 20); // 8 per sec
		attacks[AttackLevel.ULT] = new AutoDamage(this, ULT, 150, 15); // 10 per sec
		
		var debuffs:Array<BaseDebuff> = [];
		
		var int:Interactive = {
			shape : new Circle(537 - 22, 231 - 22, 60),
			enabled : true,
			onOver: () -> hxd.System.setCursor(Button),
			onOut: () -> hxd.System.setCursor(Default),
			onSelect: () -> Command.queue(CLICK(this))
		};
		
		var critInfo = new CritInfo(0.25, 2);
		
		ecs.setComponents(this, anim, attacks, debuffs, int, critInfo, 0xff5934ff, Character.DRAGOON); // sprite already created
		Command.queueMany(
			UNLOCK(this, BASIC),
			ADD_UPDATER(this, critInfo.updater)
		);
	}
}