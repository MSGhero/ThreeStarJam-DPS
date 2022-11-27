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
			loop : true,
			fps : 3,
			frames : sheet.map(["axe_idle", "axe_windup", "axe_swing", "axe_swing"]) // this isn't great, need ref to spritesheet here which I'm trying to avoid
			// maybe supply the strings and animsys creates the tile array? but then the sheet needs to be a compo or something
			// hmm
		})
		.add({
			name : "idle",
			loop : false,
			fps : 1,
			frames : sheet.map(["axe_idle"])
		});
		anim.play("idle");
		
		var attacks = new Vector<BaseAttack>(AttackLevel.ULT + 1);
		attacks[AttackLevel.BASIC] = new Click(this, 2);
		attacks[AttackLevel.AUTO] = new AutoDamage(this, 1, 0.5);
		attacks[AttackLevel.DOT] = new DoTCast(this, 1, 3, 1, 10);
		attacks[AttackLevel.ADV] = new AutoDamage(this, 5, 10);
		attacks[AttackLevel.ULT] = new AutoDamage(this, 50, 60);
		
		var debuffs:Array<BaseDebuff> = [];
		
		var critInfo = new CritInfo(0.25, 2);
		
		var int:Interactive = {
			shape : new Circle(464, 463, 92),
			enabled : true,
			onOver: () -> hxd.System.setCursor(Button),
			onOut: () -> hxd.System.setCursor(Default),
			onSelect: () -> Command.queue(CLICK(this))
		};
		
		ecs.setComponents(this, anim, attacks, debuffs, int, critInfo, 0xfffc5c65, Character.WARRIOR); // sprite already created
		Command.queueMany(
			UNLOCK(this, BASIC),
			ADD_UPDATER(this, critInfo.updater)
		);
	}
}