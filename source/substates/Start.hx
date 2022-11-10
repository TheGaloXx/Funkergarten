package substates;

import flixel.FlxG;
import lime.app.Application;

using StringTools;

class Start extends MusicBeatState
{
	override function create()
	{
        Application.current.window.title = (Main.appTitle + ' - Loading...');

		FlxG.save.data.compiles++;
		trace("TIMES COMPILED: " + FlxG.save.data.compiles);

        FlxG.mouse.visible = false;

        FlxG.worldBounds.set(0,0);

        //starting stuff i guess aaa

		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}
		
		PlayerSettings.init();

		FlxG.save.bind('funkergarten', 'funkergarten');

		KadeEngineData.initSave();
		
		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			if (menus.StoryMenuState.weekUnlocked.length < 4)
				menus.StoryMenuState.weekUnlocked.insert(0, true);

			if (!menus.StoryMenuState.weekUnlocked[0])
				menus.StoryMenuState.weekUnlocked[0] = true;
		}

        trace('hello');

        //end of start stuff i guess


		//anti leak stuff
		FlxG.switchState(new substates.AntiLeaks());
        //FlxG.switchState(new substates.Caching());

        super.create();
    }
}