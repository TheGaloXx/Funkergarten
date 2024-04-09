package substates;

import openfl.filters.ColorMatrixFilter;
import options.ColorblindMenu;
import data.KadeEngineData;
import flixel.FlxG;

class Start extends funkin.MusicBeatState
{
	override function create()
	{
		initShit();

		// funkin.MusicBeatState.switchState(new substates.AntiLeaks());
		funkin.MusicBeatState.switchState(new substates.Caching());

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
		data.FCs.init();
		Language.populate();

		#if debug
		data.KadeEngineData.other.data.compiles++;
		trace("TIMES COMPILED: " + data.KadeEngineData.other.data.compiles);
		#end
		
		data.KadeEngineData.flush();
	}

	private function settingsShit()
	{
		FlxG.sound.volume = 1;
		FlxG.sound.muted = FlxG.fixedTimestep = false; //what does this do - it makes sure that the shit isnt tied to fps apparently
		FlxG.mouse.visible = FlxG.mouse.enabled = true;
		FlxG.mouse.useSystemCursor = false;

		FlxG.sound.volumeUpKeys = [];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.muteKeys = []; // why would you mute a rhythm game

		FlxG.game.focusLostFramerate = 30;

		FlxG.signals.preStateSwitch.add(function () {
			FlxG.bitmap.dumpCache();
			// gc();
			FlxG.mouse.visible = true;
		});

		FlxG.signals.preStateCreate.add(function (_) 
		{
			Cache.uncachCharacters();
		});

		FlxG.signals.postStateSwitch.add(function () {
			// gc();
			FlxG.mouse.visible = true;
			(cast (openfl.Lib.current.getChildAt(0), Main)).updateClassIndicator();

			// Cache.check();
			// Cache.uncachCharacters();
		});

		lime.app.Application.current.onExit.add(function(exitCode)
			{
				#if debug
				data.KadeEngineData.chart_autosave.flush();
				#end

				data.KadeEngineData.flush();
				#if sys
				Sys.exit(0);
				#end
			});

		final type = KadeEngineData.settings.data.colorblind;

		if (type == 'No filter')
            FlxG.game.setFilters([]);
        else
            FlxG.game.setFilters([new ColorMatrixFilter(ColorblindMenu.typesMap.get(type))]);

		FlxG.fullscreen = KadeEngineData.settings.data.fullscreen;
	}

	private function gc() {
		#if cpp
		cpp.vm.Gc.run(true);
		#else
		openfl.system.System.gc();
		#end
	}
}