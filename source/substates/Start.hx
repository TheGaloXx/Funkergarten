package substates;

import cpp.vm.Gc;
import flixel.FlxG;
import lime.app.Application;

using StringTools;

class Start extends MusicBeatState
{
	override function create()
	{

		FlxG.save.data.compiles++;
		trace("TIMES COMPILED: " + FlxG.save.data.compiles);

        FlxG.mouse.visible = false;

        FlxG.worldBounds.set(0,0);

        //starting stuff i guess aaa

		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}
		
		CoolUtil.title('Loading...');
		#if windows
		Discord.DiscordClient.initialize();
		#end

		PlayerSettings.init();

		FlxG.save.bind('funkergarten' #if (flixel < "5.0.0"), 'funkergarten' #end);

		KadeEngineData.initSave();
		
		Highscore.load();

		Application.current.onExit.add(function(exitCode)
			{
				FlxG.save.flush();
				#if sys
				Sys.exit(0);
				#end
			});
		
		FlxG.signals.preStateSwitch.add(function () {
			FlxG.bitmap.dumpCache();
			gc();
		});
		FlxG.signals.postStateSwitch.add(function () {
			gc();
		});
	
		FlxG.sound.volume = 1;
		FlxG.sound.muted = false;
		FlxG.fixedTimestep = false; //what does this do - it makes sure that the shit isnt tied to fps apparently
		FlxG.mouse.useSystemCursor = true;

        trace('hello');

        //end of start stuff i guess

		//anti leak stuff
		MusicBeatState.switchState(new substates.AntiLeaks());
        //FlxG.switchState(new substates.Caching());

        super.create();
    }

	public static function gc() {
		#if cpp
		Gc.run(true);
		#else
		openfl.system.System.gc();
		#end
	}
}