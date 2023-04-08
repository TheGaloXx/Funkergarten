package substates;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxTimer;
#if cpp
import sys.thread.Thread;
#end

using StringTools;

class LoadingState extends MusicBeatState
{
	public static var target:FlxState;
	public static var stopMusic = false;

	static var imagesToCache:Array<String> = [];
	static var soundsToCache:Array<String> = [];

	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();

		// Hardcoded, aaaaahhhh
		switch (PlayState.SONG.song)
		{
			case 'Monday':
				soundsToCache = ["bite"];

				imagesToCache = ['gameplay/apple', 'gameplay/pixel/apple'];
		}

		imagesToCache.push('gameplay/icons');
		imagesToCache.push('icons');
		for (i in 1...3)
			soundsToCache.push('missnote' + i);

		soundsToCache.push('text');

		FlxGraphic.defaultPersist = true;
		#if cpp
		Thread.create(() ->
		{
			for (sound in soundsToCache)
			{
				trace("Caching sound " + sound);
				FlxG.sound.cache(Paths.sound(sound, 'shared'));
			}

			for (image in imagesToCache)
			{
				trace("Caching image " + image);
				FlxG.bitmap.add(Paths.image(image, 'shared'));
			}

			FlxGraphic.defaultPersist = false;

			trace("Done caching");
			
			new FlxTimer().start(0.5, function(_:FlxTimer)
			{
				loadAndSwitchState(target, false);
			});
		});
		#end
	}

	public static function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		MusicBeatState.switchState(target);
	}
}