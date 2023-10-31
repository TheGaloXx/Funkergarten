package substates;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;

using StringTools;

class Caching extends funkin.MusicBeatState
{
	var text:FlxText;

	var images:Array<FlxGraphic> = [];
	var music = [];

	override function create()
	{
        CoolUtil.title('Loading...');
		
		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300, 0, "Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
		text.screenCenter();
        add(text);

		trace('starting caching..');

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

	override function update(elapsed)
	{
		super.update(elapsed);
	}

	function cache()
	{
        // store this or else nothing will be saved
		// Thanks Shubs -sqirra
		FlxGraphic.defaultPersist = true;

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

        FlxGraphic.defaultPersist = false;

		funkin.MusicBeatState.switchState(new states.TitleState());
	}
}