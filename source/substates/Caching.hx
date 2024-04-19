package substates;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import funkin.MusicBeatState;
import states.TitleState;

using StringTools;

class Caching extends MusicBeatState
{
	override function create()
	{
        CoolUtil.title('Loading...');

		trace('Starting caching...');

		#if sys
		sys.thread.Thread.create(() ->
		{
			try
			{
				cache();
			}
			catch (e)
			{
				trace('ERROR: ${e.message}!');
			}
		});
		#else
		funkin.MusicBeatState.switchState(new states.TitleState());
		#end

		super.create();
	}

	override function update(e){}
	override function draw(){}

	private inline function cache()
	{
		var images:Array<FlxGraphic> = [];

		inline function cacheImage(path:String):Void
			images.push(FlxG.bitmap.add(Paths.image(path, 'shared')));

        // store this or else nothing will be saved
		// Thanks Shubs -sqirra
		FlxGraphic.defaultPersist = true;

		function bitmapsLength():Void
		{
			var length:Int = 0;
			@:privateAccess
			for (key => i in FlxG.bitmap._cache)
				length++;
	
			trace('Cached assets: $length.');
		}

		bitmapsLength();

		cacheImage("gameplay/notes/noteSplashes");
		cacheImage("gameplay/pixel/noteSplashes");
		cacheImage("gameplay/notes/apple");
		cacheImage('gameplay/notes/NOTE_nugget_poisoned');
		cacheImage('gameplay/notes/NOTE_assets');
		cacheImage('gameplay/pixel/NOTE_assets');

		for (i in images)
		{
            FlxG.bitmap.add(i);
			i.persist = true;
            i.destroyOnNoUse = false;
		}

        FlxGraphic.defaultPersist = false;

		bitmapsLength();

		#if SKIP_TO_CHARTINGSTATE
		PlayState.SONG = Song.loadFromJson(Highscore.formatSong('nugget', 2), 'nugget', false);
		MusicBeatState.switchState(new ChartingState(), true);
		#else
		MusicBeatState.switchState(new TitleState());
		#end
	}
}