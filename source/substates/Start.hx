package substates;

import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.graphics.FlxGraphic;
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

		FlxG.save.bind('funkergarten' #if (flixel < "5.0.0"), 'funkergarten' #end);

		KadeEngineData.initSave();
		
		Highscore.load();

		Application.current.onExit.add(function(exitCode)
			{
				FlxG.save.flush();
				Sys.exit(0);
			});
	
		FlxG.sound.volume = 1;
		FlxG.sound.muted = false;
		FlxG.fixedTimestep = false; //what does this do
		FlxG.mouse.useSystemCursor = true;
		FlxScreenGrab.defineCaptureRegion(0, 0, FlxG.width, FlxG.height);
		FlxScreenGrab.grab(null, false, true);

        trace('hello');

        //end of start stuff i guess


		//anti leak stuff
		FlxG.switchState(new substates.AntiLeaks());
        //FlxG.switchState(new substates.Caching());

        super.create();
    }
}