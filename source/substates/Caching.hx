package substates;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;

using StringTools;

class Caching extends funkin.MusicBeatState
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

        // store this or else nothing will be saved
		// Thanks Shubs -sqirra
		FlxGraphic.defaultPersist = true;

		Cache.length();

		var splashes:FlxGraphic = FlxG.bitmap.add(Paths.image("gameplay/notes/noteSplashes", 'shared'));
        var pixelSplashes:FlxGraphic = FlxG.bitmap.add(Paths.image("gameplay/pixel/noteSplashes", 'shared'));
        images.push(splashes);
		images.push(pixelSplashes);

		var apples:FlxGraphic = FlxG.bitmap.add(Paths.image("gameplay/notes/apple", 'shared'));
        images.push(apples);

        var nuggetsP:FlxGraphic = FlxG.bitmap.add(Paths.image('gameplay/notes/NOTE_nugget_poisoned', 'shared'));
        images.push(nuggetsP);

		var noteAssets:FlxGraphic = FlxG.bitmap.add(Paths.image('gameplay/notes/NOTE_assets', 'shared'));
        var pixelEnd:FlxGraphic = FlxG.bitmap.add(Paths.image('gameplay/pixel/arrowEnds', 'shared'));

		images.push(noteAssets);
        images.push(pixelEnd);

		for (i in images)
		{
            FlxG.bitmap.add(i);
			i.persist = true;
            i.destroyOnNoUse = false;
		}

		Cache.length();

        FlxGraphic.defaultPersist = false;

		Cache.length();

		funkin.MusicBeatState.switchState(new states.TitleState());
	}
}