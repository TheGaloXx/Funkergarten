package substates;

import lime.app.Application;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import flixel.ui.FlxBar;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;

using StringTools;

class Caching extends MusicBeatState
{
	var text:FlxText;

	var images:Array<FlxGraphic> = [];
	var music = [];

	override function create()
	{
        Application.current.window.title = (Main.appTitle + ' - Loading...');

		FlxG.mouse.visible = false;

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300, 0, "Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
        add(text);

		FlxGraphic.defaultPersist = true;

		trace('starting caching..');

		sys.thread.Thread.create(() ->
		{
			cache();
		});

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

        //splashes
		var splashes:FlxGraphic = FlxG.bitmap.add(Paths.image("gameplay/notes/noteSplashes", 'shared')); //splashes
        var pixelSplashes:FlxGraphic = FlxG.bitmap.add(Paths.image("gameplay/pixel/noteSplashes", 'shared')); //pixel splashes
        var gumSplashes:FlxGraphic = FlxG.bitmap.add(Paths.image('gameplay/notes/gumSplash', 'shared'));

        images.push(splashes);
		images.push(pixelSplashes);
        images.push(gumSplashes);
        
        //apples
		var apples:FlxGraphic = FlxG.bitmap.add(Paths.image("gameplay/notes/NOTE_apple", 'shared')); 
        var pixelApples:FlxGraphic = FlxG.bitmap.add(Paths.image("gameplay/pixel/NOTE_apple", 'shared'));

        images.push(apples);
        images.push(pixelApples);
		
        //gum           I should put the 3 gum assets togheter
        var gumNotes:FlxGraphic = FlxG.bitmap.add(Paths.image('gameplay/notes/NOTE_gum', 'shared'));
        var gumTrap:FlxGraphic = FlxG.bitmap.add(Paths.image('gameplay/notes/Gum_trap', 'shared'));

        images.push(gumNotes);
        images.push(gumTrap);

        //nuggets
        var nuggetsN:FlxGraphic = FlxG.bitmap.add(Paths.image('gameplay/notes/NOTE_nugget_normal', 'shared'));
        var nuggetsP:FlxGraphic = FlxG.bitmap.add(Paths.image('gameplay/notes/NOTE_nugget_poisoned', 'shared'));

        images.push(nuggetsN);
        images.push(nuggetsP);

        //notes
		var noteAssets:FlxGraphic = FlxG.bitmap.add(Paths.image('gameplay/notes/NOTE_assets', 'shared'));
        var pixelEnd:FlxGraphic = FlxG.bitmap.add(Paths.image('gameplay/pixel/arrowEnds', 'shared'));

		images.push(noteAssets);
        images.push(pixelEnd);

		FlxG.sound.cache(Paths.sound('extra/SNAP', 'shared'));

        /*
        trace('starting vid cache');
		var video:VideoHandler = new VideoHandler();
		video.finishCallback = null;
		video.playVideo(Paths.video('aaaaaaaaaaaaaaaaaaa.mp4'));
        //oof.  anyways I don't think we're gonna need to cache a video lmao
        */

		for (i in images)
		{
            FlxG.bitmap.add(i);
			i.persist = true;
            i.destroyOnNoUse = false;

            trace(i);
		}

        /*
		for (i in sounds)
		{
            if (i != null)
			    FlxG.sound.cache(i);

            trace(FlxG.sound.list);
		}
        */

        FlxGraphic.defaultPersist = false;

		FlxG.switchState(new menus.TitleState());
	}
}