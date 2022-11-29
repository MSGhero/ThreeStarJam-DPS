package audio;

import hxd.Res;
import hxd.snd.SoundGroup;
import command.Command;
import haxe.ds.StringMap;
import ecs.Universe;
import ecs.System;
import hxd.snd.Manager;
import hxd.snd.Channel;
import input.Input;
import audio.AudioCommand;

// this one isn't done, but it's decent now
class AudioSystem extends System {
	
	@:fullFamily
	var audio : {
		resources : {
			manager:Manager,
			volumeInfo:AudioVolume
		},
		requires : {
			channel:Channel,
			info:AudioInfo
		}
	};
	
	@:fullFamily
	var mute : {
		resources : {
			manager:Manager
		},
		requires : {
			input:Input
		}
	};
	
	var sfxGroup:SoundGroup;
	var uiGroup:SoundGroup;
	
	var taggedSounds:StringMap<Channel>;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		sfxGroup = new SoundGroup("sfx");
		uiGroup = new SoundGroup("ui");
		
		taggedSounds = new StringMap();
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		Command.register(PLAY(MUSIC, "", false, 0, ""), handleAC);
		Command.register(STOP_BY_TYPE(MUSIC), handleAC);
		Command.register(STOP_BY_TAG(""), handleAC);
		Command.register(RESET_VOLUME, handleAC);
	}
	
	function handleAC(ac:AudioCommand) {
		
		switch (ac) {
			case PLAY(type, resPath, loop, volume, tag):
				setup(audio, {
					
					var snd = Res.load(resPath).toSound();
					var channel:Channel = null;
					var info:AudioInfo = {
						type : type,
						loop : loop,
						volume : volume
					};
					
					var useTag = tag != null && tag.length > 0;
					
					// there's a bug with ECS and exhaustiveness checks, need to submit new issue
					// untyped for now
					untyped switch (type) {
						case MUSIC:
							channel = manager.play(snd);
							info.tag = useTag ? tag : "music";
							info.volume *= volumeInfo.musicMult;
							taggedSounds.set(info.tag, channel);
						case VOICE:
							channel = manager.play(snd);
							info.tag = useTag ? tag : "voice";
							info.volume *= volumeInfo.voiceMult;
							taggedSounds.set(info.tag, channel);
						case SFX:
							channel = manager.play(snd, sfxGroup);
							if (useTag) {
								info.tag = tag;
								taggedSounds.set(info.tag, channel);
							}
							else info.tag = "sfx";
							info.volume *= volumeInfo.sfxMult;
						case UI:
							channel = manager.play(snd, uiGroup);
							if (useTag) {
								info.tag = tag;
								taggedSounds.set(info.tag, channel);
							}
							else info.tag = "ui";
							info.volume *= volumeInfo.uiMult;
					}
					
					universe.setComponents(universe.createEntity(), channel, info);
				});
			case STOP_BY_TYPE(type):
				switch (type) {
					case MUSIC: taggedSounds.get("music").stop();
					case VOICE: taggedSounds.get("voice").stop();
					case SFX: setup(audio, { manager.stopByName("sfx"); });
					case UI: setup(audio, { manager.stopByName("ui"); });
				}
			case STOP_BY_TAG(tag):
				taggedSounds.get(tag).stop();
			case RESET_VOLUME:
				// when volumeInfo gets changed, update all existing sounds
		}
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		setup(mute, {
			iterate(mute, {
				if (input.actions.justPressed.MUTE) {
					trace("K");
					manager.suspended = !manager.suspended;
				}
			});
		});
	}
}