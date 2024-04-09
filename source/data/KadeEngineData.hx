package data;

import funkin.Conductor;
import flixel.FlxSprite;
import flixel.FlxG;

class KadeEngineData
{
	public static var other    		 = new flixel.util.FlxSave();
	public static var settings 		 = new flixel.util.FlxSave();
	public static var controls 		 = new flixel.util.FlxSave();
	public static var chart_autosave = new flixel.util.FlxSave();

	public static var showHelp:Bool = true;
	public static var botplay:Bool = false;
	public static var practice:Bool = false;

    public static function initSave()
    {
		initSettings();

		#if debug
		other.data.compiles ??= 0;

		chart_autosave.data.chart ??= {};
		#end

		other.data.mondays ??= 0;
		other.data.showCharacters ??= ['protagonist'];
		other.data.beatedMod ??= false; // typo :sob:
		other.data.beatedSongs ??= [];  // typo :sob:
		other.data.gotSkin ??= false;
		other.data.talkedNugget ??= false;
		other.data.seenCredits ??= false;
		other.data.polla ??= false;
		other.data.sawAdvice ??= false;
		other.data.usingSkin ??= false;
		other.data.didV0 ??= false;

		FlxSprite.defaultAntialiasing = settings.data.antialiasing;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		keyCheck();

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
			other.data.didV0 = false;
			Highscore.load();
			FCs.init();

			flush();
		}

	public static function initSettings():Void
	{
		settings.data.downscroll ??= false;
		settings.data.fps ??= false;
		settings.data.mechanics ??= true;
		settings.data.antialiasing ??= true;
		settings.data.camMove ??= true;
		settings.data.fullscreen ??= false;
		settings.data.middlescroll ??= false;
		settings.data.lowQuality ??= false;
		settings.data.flashing ??= true;
		settings.data.shaders ??= true;
		settings.data.ghostTap ??= true;
		settings.data.colorblind ??= 'No filter';
		settings.data.zooms ??= true;
		settings.data.fpsCap ??= 60;

		if (settings.data.fpsCap > 240 || settings.data.fpsCap < 60)
			settings.data.fpsCap = 60;

		if (settings.data.changedHit == null)
		{
			settings.data.changedHitX = settings.data.changedHitY = -1;
			settings.data.changedHit = false;
		}
	}

    public static function resetBinds():Void
	{
        controls.data.upBind = "W";
        controls.data.downBind = "S";
        controls.data.leftBind = "A";
        controls.data.rightBind = "D";

        PlayerSettings.player1.controls.loadKeyBinds();
	}

    public static function keyCheck():Void
    {
		controls.data.upBind ??= "W";

        if (StringTools.contains(controls.data.upBind, "NUMPAD"))
            controls.data.upBind = "W";
	
		controls.data.downBind ??= "S";

        if (StringTools.contains(controls.data.downBind, "NUMPAD"))
            controls.data.downBind = "S";

		controls.data.leftBind ??= "A";

        if (StringTools.contains(controls.data.leftBind, "NUMPAD"))
            controls.data.leftBind = "A";

		controls.data.rightBind ??= "D";

        if (StringTools.contains(controls.data.rightBind, "NUMPAD"))
            controls.data.rightBind = "D";

        trace('KEYBINDS: [${controls.data.leftBind} - ${controls.data.downBind} - ${controls.data.upBind} - ${controls.data.rightBind}].');
    }

	public static function bind():Void
	{
		trace("Creating/reconnecting data!");

		other.bind('other', 'funkergarten');
		settings.bind('settings', 'funkergarten');
		controls.bind('controls', 'funkergarten');

		#if debug
		chart_autosave.bind('chart_autosave', 'funkergarten');
		#end
	}

	public static function flush():Void
	{
		trace("Saving data!");

		other.flush();
		settings.flush();
		controls.flush();
	}
}