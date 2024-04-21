package states;

import Discord.DiscordClient;
import lime.app.Application;
import openfl.filters.ColorMatrixFilter;
import options.ColorblindMenu;
import flixel.FlxG;
import funkin.MusicBeatState;
import data.*;

class Start extends MusicBeatState
{
	override function create()
	{
		initShit();

		// MusicBeatState.switchState(new states.AntiLeaks());
		MusicBeatState.switchState(new states.Caching());

        super.create();
    }

	private function initShit()
	{
		CoolUtil.title('Loading...');

		DiscordClient.initialize();

		dataShit();
		settingsShit();

		trace('hello');
	}

	private function dataShit()
	{
		GlobalData.initSave();
		Highscore.load();
		FCs.init();
		Language.populate();

		#if debug
		GlobalData.autoUnlock();
		#end

		GlobalData.flush();
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

		FlxG.signals.preStateSwitch.add(function ()
		{
			FlxG.bitmap.dumpCache();
			FlxG.mouse.visible = true;
		});

		FlxG.signals.preStateCreate.add(function (_) 
		{
			CoolUtil.uncachCharacters();
		});

		FlxG.signals.postStateSwitch.add(function ()
		{
			FlxG.mouse.visible = true;
			(cast (openfl.Lib.current.getChildAt(0), Main)).updateClassIndicator();
		});

		Application.current.onExit.add(function(exitCode)
		{
			#if debug
			GlobalData.chart_autosave.flush();
			#end

			GlobalData.flush();

			#if sys
			Sys.exit(0);
			#end
		});

		final type = GlobalData.settings.colorblindType;

		if (type == 'No filter')
            FlxG.game.setFilters([]);
        else
            FlxG.game.setFilters([new ColorMatrixFilter(ColorblindMenu.typesMap.get(type))]);

		FlxG.fullscreen = GlobalData.settings.fullscreen;
	}

	private function gc()
	{
		#if cpp
		cpp.vm.Gc.run(true);
		#else
		openfl.system.System.gc();
		#end
	}
}