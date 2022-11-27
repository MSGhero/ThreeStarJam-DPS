package command;

import haxe.EnumTools.EnumValueTools;

abstract Command(EnumValue) from EnumValue to EnumValue {
	
	@:to
	public inline function toString() {
		return EnumValueTools.getName(this);
	}
	
	public static function queue(command:Command) {
		@:privateAccess(CommandSystem)
		CommandSystem._cmdSys.enqueue(command);
	}
	
	public static function queueMany(...commands:Command) {
		
		for (command in commands) {
			@:privateAccess(CommandSystem)
			CommandSystem._cmdSys.enqueue(command);
		}
	}
	
	public static function register<T>(type:Command, callback:T->Void) {
		queue(CoreCommand.REGISTER(type, cast callback));
	}
}