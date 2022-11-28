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
abstract Mage(BaseChar) to BaseChar {
	
	public function new(ecs:Universe, sheet:Spritesheet) {
		this = new BaseChar(ecs.createEntity());
		
		var anim = new Animation();
		anim.add({
			name : "attack",
			loop : false,
			fps : 12,
			frames : sheet.map(["staff_idle", "staff_ready", "staff_cast", "staff_cast", "staff_idle"]) // this isn't great, need ref to spritesheet here which I'm trying to avoid
		})
		.add({
			name : "idle",
			loop : false,
			fps : 1,
			frames : sheet.map(["staff_idle"])
		})
		.add({
			name : "dot",
			loop : false,
			fps : 12,
			frames : sheet.map(["staff_idle", "staff_ready_dot", "staff_ready_dot", "staff_cast_dot", "staff_cast_dot", "staff_cast_dot", "staff_cast_dot", "staff_idle"])
		})
		.add({
			name : "adv",
			loop : false,
			fps : 6,
			frames : sheet.map(["staff_idle", "staff_pre_adv", "staff_cast_adv", "staff_cast_adv", "staff_flash_adv", "staff_cast_adv", "staff_cast_adv", "staff_idle"])
		})
		;
		
		anim.play("idle");
		
		var attacks = new Vector<BaseAttack>(AttackLevel.ULT + 1);
		attacks[AttackLevel.BASIC] = new Click(this, BASIC, 1);
		attacks[AttackLevel.AUTO] = new AutoDamage(this, AUTO, 1, 0.5);
		attacks[AttackLevel.DOT] = new DoTCast(this, DOT, 1, 3, 1, 5);
		attacks[AttackLevel.ADV] = new AutoDamage(this, ADV, 5, 10);
		attacks[AttackLevel.ULT] = new AutoDamage(this, ULT, 50, 60);
		
		var debuffs:Array<BaseDebuff> = [];
		
		var int:Interactive = {
			shape : new Circle(769, 427, 92),
			enabled : true,
			onOver: () -> hxd.System.setCursor(Button),
			onOut: () -> hxd.System.setCursor(Default),
			onSelect: () -> Command.queue(CLICK(this))
		};
		
		var critInfo = new CritInfo(0.25, 2);
		
		ecs.setComponents(this, anim, attacks, debuffs, int, critInfo, 0xffffb600, Character.MAGE); // sprite already created
		Command.queueMany(
			UNLOCK(this, BASIC),
			UNLOCK(this, ADV),
			ADD_UPDATER(this, critInfo.updater)
		);
	}
}