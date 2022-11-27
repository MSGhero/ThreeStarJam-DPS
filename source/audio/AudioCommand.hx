package audio;

import audio.AudioType;

enum AudioCommand {
	PLAY(type:AudioType, resPath:String, loop:Bool, volume:Float, tag:String);
	STOP_BY_TYPE(type:AudioType);
	STOP_BY_TAG(tag:String);
	RESET_VOLUME;
}