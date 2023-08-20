package substates;

import flixel.FlxG;

class Start extends funkin.MusicBeatState
{
	override function create()
	{
		initShit();

		funkin.MusicBeatState.switchState(new substates.AntiLeaks());

        super.create();
    }

	private function initShit()
	{
		CoolUtil.title('Loading...');

		#if windows
		Discord.DiscordClient.initialize();
		#end

		dataShit();
		settingsShit();

		trace('hello');
	}

	private function dataShit()
	{
		data.PlayerSettings.init();
		data.KadeEngineData.initSave();
		data.Highscore.load();

		#if debug
		data.KadeEngineData.other.data.compiles++;
		trace("TIMES COMPILED: " + data.KadeEngineData.other.data.compiles);
		#end
		
		data.KadeEngineData.flush();
	}

	private function settingsShit()
	{
		FlxG.worldBounds.set(0,0);
		FlxG.sound.volume = 1;
		FlxG.sound.muted = FlxG.fixedTimestep = false; //what does this do - it makes sure that the shit isnt tied to fps apparently
		FlxG.mouse.visible = FlxG.mouse.enabled = true;
		FlxG.mouse.useSystemCursor = false;

		#if debug 
		FlxG.sound.volumeUpKeys = [Q, PLUS];
		#end

		FlxG.sound.muteKeys = [];	//why would you mute a rhythm game
		FlxG.game.focusLostFramerate = 60;

		FlxG.signals.preStateSwitch.add(function () {
			FlxG.game.setFilters([]);
			FlxG.bitmap.dumpCache();
			gc();
			FlxG.mouse.visible = true;
		});
		FlxG.signals.postStateSwitch.add(function () {
			gc();
			FlxG.mouse.visible = true;
			(cast (openfl.Lib.current.getChildAt(0), Main)).updateClassIndicator();
			trace('Cameras: ${FlxG.cameras.list.length}');
		});

		lime.app.Application.current.onExit.add(function(exitCode)
			{
				data.KadeEngineData.flush();
				#if sys
				Sys.exit(0);
				#end
			});
	}

	private function gc() {
		#if cpp
		cpp.vm.Gc.run(true);
		#else
		openfl.system.System.gc();
		#end
	}
}