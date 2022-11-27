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
			loop : true,
			fps : 3,
			frames : sheet.map(["staff_idle", "staff_ready", "staff_cast", "staff_cast"]) // this isn't great, need ref to spritesheet here which I'm trying to avoid
		})
		.add({
			name : "idle",
			loop : false,
			fps : 1,
			frames : sheet.map(["staff_idle"])
		});
		anim.play("idle");
		
		var attacks = new Vector<BaseAttack>(AttackLevel.ULT + 1);
		attacks[AttackLevel.BASIC] = new Click(this, 1);
		attacks[AttackLevel.AUTO] = new AutoDamage(this, 1, 0.5);
		attacks[AttackLevel.DOT] = new DoTCast(this, 1, 3, 1, 10);
		attacks[AttackLevel.ADV] = new AutoDamage(this, 5, 10);
		attacks[AttackLevel.ULT] = new AutoDamage(this, 50, 60);
		
		var debuffs:Array<BaseDebuff> = [];
		
		var int:Interactive = {
			shape : new Circle(769, 427, 92),
			enabled : true,
			onOver: () -> hxd.System.setCursor(Button),
			onOut: () -> hxd.System.setCursor(Default),
			onSelect: () -> Command.queue(AttackCommand.CLICK(this))
		};
		
		var critInfo = new CritInfo(0.25, 2);
		
		ecs.setComponents(this, anim, attacks, debuffs, int, critInfo, Character.MAGE); // sprite already created
		Command.queueMany(
			AttackCommand.UNLOCK(this, BASIC),
			TimingCommand.ADD_UPDATER(this, critInfo.updater)
		);
	}
}