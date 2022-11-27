package graphics;

import h2d.Bitmap;
import timing.TimingCommand;
import command.Command;
import ecs.Universe;
import ecs.System;

class AnimSystem extends System {
	
	@:fastFamily
	var spriteAnims : {
		anim:Animation,
		sprite:Sprite
	}
	
	@:fastFamily
	var bitmapAnims : {
		anim:Animation,
		bitmap:Bitmap
	}
	
	public function new(ecs:Universe) {
		super(ecs);
		
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		spriteAnims.onEntityAdded.subscribe(handleSpriteAnim);
		bitmapAnims.onEntityAdded.subscribe(handleBitmapAnim);
	}
	
	function handleSpriteAnim(entity) {
		
		fetch(spriteAnims, entity, {
			sprite.t = anim.currFrame;
			anim.onFrame = () -> sprite.t = anim.currFrame;
			Command.queue(TimingCommand.ADD_UPDATER(entity, anim.updater));
		});
	}
	
	function handleBitmapAnim(entity) {
		
		fetch(bitmapAnims, entity, {
			bitmap.tile = anim.currFrame;
			anim.onFrame = () -> bitmap.tile = anim.currFrame;
			Command.queue(TimingCommand.ADD_UPDATER(entity, anim.updater));
		});
	}
}