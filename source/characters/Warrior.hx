package characters;

import interactive.shapes.Circle;
import interactive.Interactive;
import attacks.Click;
import attacks.AttackCommand;
import command.Command;
import attacks.DoTCast;
import attacks.AutoDamage;
import attacks.base.BaseDebuff;
import attacks.base.BaseBuff;
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
		
		var buffs:Array<BaseBuff> = [];
		var debuffs:Array<BaseDebuff> = [];
		
		var int:Interactive = {
			shape : new Circle(464, 463, 92),
			enabled : true,
			onOver: () -> hxd.System.setCursor(Button),
			onOut: () -> hxd.System.setCursor(Default),
			onSelect: () -> attacks[0].oneTime(),
		};
		
		ecs.setComponents(this, anim, attacks, buffs, debuffs, int, Character.WARRIOR); // sprite already created
		Command.queue(AttackCommand.UNLOCK(this, BASIC));
	}
}