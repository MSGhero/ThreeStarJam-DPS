package input;

import haxe.ds.IntMap;
import command.Command;
import ecs.Universe;
import ecs.System;
import input.InputCommand;

class InputSystem extends System {
	
	@:fullFamily
	var inputs : {
		requires : {
			input:Input
		}
	};
	
	var inputMap:IntMap<Input>;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		inputMap = new IntMap();
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		Command.register(ADD_INPUT(null, DEBUG), handleInput);
		Command.register(ENABLE_INPUT(DEBUG), handleInput);
		Command.register(DISABLE_INPUT(DEBUG), handleInput);
	}
	
	function handleInput(ic:InputCommand) {
		
		switch (ic) {
			case ADD_INPUT(input, id):
				inputMap.set(id, input);
				universe.setComponents(universe.createEntity(), input);
			case ENABLE_INPUT(id):
				inputMap.get(id).enabled = true;
			case DISABLE_INPUT(id):
				inputMap.get(id).enabled = false;
			default:
		}
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		// reset on focus lost or something?
		
		iterate(inputs, {
			
			input.previous.copyFrom(input.actions);
			
			for (i in 0...input.pressed.length)
				input.pressed[i] = false;
			
			if (input.enabled) {
				
				for (device in input.devices) {
					
					for (i in 0...input.pressed.length) {
						if (input.pressed[i]) continue;
						input.pressed[i] = device.getStatus(i);
					}
				}
			}
			
			input.actions.updateJust(input.previous);
		});
	}
}