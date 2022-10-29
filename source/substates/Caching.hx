package substates;

import flixel.graphics.FlxGraphic;
import sys.FileSystem;
import flixel.FlxG;
import lime.app.Application;
import flixel.text.FlxText;

using StringTools;

class Caching extends MusicBeatState
{
    var text:FlxText;

	override function create()
	{
        text = new FlxText(0, 0, 0,"Loading...");
        text.size = 34;
        text.alignment = FlxTextAlign.CENTER;
        text.screenCenter();
        add(text);

        trace('starting caching..');
        
        sys.thread.Thread.create(() -> {
            cache();
        });


        super.create();
    }

    function cache()
    {
        Application.current.window.title = (Main.appTitle + ' - Caching...');

        var images = [];
        var music = [];

        trace("caching images...");

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images")))
        {
            if (!i.endsWith(".png"))
                continue;
            images.push(i);
        }

        FlxGraphic.defaultPersist = true;

        trace("caching music...");

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
        {
            music.push(i);
        }

        for (i in images)
        {
            var replaced = i.replace(".png", "");
            FlxG.bitmap.add(Paths.image("" + replaced, "shared"));
            trace("cached " + replaced);
        }

        for (i in music)
        {
            FlxG.sound.cache(Paths.inst(i));
            FlxG.sound.cache(Paths.voices(i));
            trace("cached " + i);
        }

        trace("Finished caching...");

        FlxG.switchState(new menus.TitleState());
    }

}