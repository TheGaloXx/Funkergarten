package data;

import input.*;
import input.Controls.SavedAction;
import input.Controls.ActionType;

class KadeEngineData
{
	public static var other    = new flixel.util.FlxSave();
	public static var settings = new flixel.util.FlxSave();
	public static var controls = new flixel.util.FlxSave();

	public static var showHelp:Bool = true;
	public static var botplay:Bool = false;
	public static var practice:Bool = false;

    public static function initSave()
    {
		initSettings();

		#if debug
		if (other.data.compiles == null)
			other.data.compiles = 0;
		#end

		if (other.data.mondays == null)
			other.data.mondays = 0;

		if (other.data.showCharacters == null)
			other.data.showCharacters = ['protagonist'];

		// typo
		if (other.data.beatedMod == null)
			other.data.beatedMod = false;

		if (other.data.gotSkin == null)
			other.data.gotSkin = false;

		// typo
		if (other.data.beatedSongs == null)
			other.data.beatedSongs = [];

		if (other.data.talkedNugget == null)
			other.data.talkedNugget = false;

		if (other.data.polla == null)
			other.data.polla = false;

		if (other.data.sawAdvice == null)
			other.data.sawAdvice = false;

		if (other.data.usingSkin == null)
			other.data.usingSkin = false;

		flixel.FlxSprite.defaultAntialiasing = settings.data.antialiasing;

		funkin.Conductor.recalculateTimings();
		reloadKeybinds();

		Main.changeFPS(settings.data.fpsCap);
	}

	public static function resetData()
		{
			//#if debug return; #end //	hehe
			other.data.mondays = 0;
			other.data.showCharacters = ['protagonist'];
			other.data.beatedMod = false;
			other.data.talkedNugget = false;
			other.data.gotSkin = false;
			other.data.beatedSongs = [];
			other.data.polla = false;
			other.data.usingSkin = false;
			other.data.songScores = null;
			other.data.fcedSongs = null;
			Highscore.load();
			FCs.init();

			flush();
		}

	public static function initSettings():Void
	{
		if (settings.data.downscroll == null)
			settings.data.downscroll = false;

		if (settings.data.fps == null)
			settings.data.fps = false;

		if (settings.data.changedHit == null)
		{
			settings.data.changedHitX = settings.data.changedHitY = -1;
			settings.data.changedHit = false;
		}

		if (settings.data.fpsCap == null)
			settings.data.fpsCap = 60; //  n o .

		if (settings.data.fpsCap > 285 || settings.data.fpsCap < 60)
			settings.data.fpsCap = 60; //baby proof so you can't hard lock ur copy of kade engine - what

		if (settings.data.mechanics == null)
			settings.data.mechanics = true;

		if (settings.data.antialiasing == null)
			settings.data.antialiasing = true;

		if (settings.data.camMove == null)
			settings.data.camMove = true;

		if (settings.data.fullscreen == null)
			settings.data.fullscreen = false;

		if (settings.data.middlescroll == null)
			settings.data.middlescroll = false;

		if (settings.data.lowQuality == null)
			settings.data.lowQuality = false;

		if (settings.data.flashing == null)
			settings.data.flashing = true;

		if (settings.data.shaders == null)
			settings.data.shaders = true;

		if (settings.data.ghostTap == null)
			settings.data.ghostTap = true;

		if (settings.data.colorblind == null)
			settings.data.colorblind = 'No filter';
	}

	public static function reloadKeybinds()
	{
		var endMap:Map<ActionType, SavedAction> = new Map();

		var actions:Array<ActionType> = [
			CONFIRM, BACK, RESET, PAUSE, UI_LEFT, UI_DOWN, UI_UP, UI_RIGHT, NOTE_LEFT, NOTE_DOWN, NOTE_UP, NOTE_RIGHT
		];

		@:privateAccess
		{
			for (action in actions)
			{
				endMap.set(action, {
					kbBinds: Keyboard.actions.get(action),
					gpBinds: Controller.actions.get(action)
				});

				var save:Null<SavedAction> = Reflect.field(controls.data, Std.string(action));
				if (save == null)
				{
					save = endMap.get(action);
					#if debug
					trace('Saved binds on $action not found');
					#end
				}

				#if debug
				trace('Saved binds on $action found $save');
				#end

				Keyboard.actions.set(action, save.kbBinds);
				Controller.actions.set(action, save.gpBinds);
			}
		}
	}

	public static function bind():Void
	{
		trace("Creating/reconnecting data!");

		other.bind('other', 'funkergarten');
		settings.bind('settings', 'funkergarten');
		controls.bind('controls', 'funkergarten');
	}

	public static function flush(doTrace = true):Void
	{
		if (doTrace)
			trace("Saving data!");

		other.flush();
		settings.flush();
		controls.flush();
	}
}