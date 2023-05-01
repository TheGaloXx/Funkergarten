package;

import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;

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

		if (other.data.gotCardDEMO == null)
			other.data.gotCardDEMO = false;

		if (other.data.tries == null)
			other.data.tries = 0;

		if (other.data.showCharacters == null)
			other.data.showCharacters = ['protagonist'];

		if (other.data.beatedMod == null)
			other.data.beatedMod = false;

		if (other.data.beatedSongs == null)
			other.data.beatedSongs = [];

		if (other.data.polla == null)
			other.data.polla = false;

		flixel.FlxSprite.defaultAntialiasing = settings.data.antialiasing;
		
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
		KeyBinds.gamepad = gamepad != null;

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
			other.data.gotCardDEMO = false;
			other.data.beatedMod = false;
			other.data.beatedSongs = [];
			other.data.polla = false;

			flush();
		}

	public static function initSettings():Void
	{
		if (settings.data.downscroll == null)
			settings.data.downscroll = false;
			
		if (settings.data.accuracyDisplay == null)
			settings.data.accuracyDisplay = true;

		if (settings.data.songPosition == null)
			settings.data.songPosition = true;

		if (settings.data.fps == null)
			settings.data.fps = false;

		if (settings.data.changedHit == null)
		{
			settings.data.changedHitX = settings.data.changedHitY = -1;
			settings.data.changedHit = false;
		}

		if (settings.data.fpsCap == null)
			settings.data.fpsCap = 120;

		if (settings.data.fpsCap > 285 || settings.data.fpsCap < 60)
			settings.data.fpsCap = 120; //baby proof so you can't hard lock ur copy of kade engine - what

		if (settings.data.mechanics == null)
			settings.data.mechanics = true;

		if (settings.data.antialiasing == null)
			settings.data.antialiasing = true;

		if (settings.data.camMove == null)
			settings.data.camMove = true;

		if (settings.data.snap == null)
			settings.data.snap = false;

		if (settings.data.fullscreen == null)
			settings.data.fullscreen = false;

		if (settings.data.middlescroll == null)
			settings.data.middlescroll = false;

		if (settings.data.distractions == null)
			settings.data.distractions = true;

		if (settings.data.flashing == null)
			settings.data.flashing = true;

		if (settings.data.shaders == null)
			settings.data.shaders = true;

		if (settings.data.musicVolume == null)
			settings.data.musicVolume = 1;

		if (settings.data.soundVolume == null)
			settings.data.soundVolume = 1;

		if (settings.data.lockSong == null)
			settings.data.lockSong = true;

		if (settings.data.ghostTap == null)
			settings.data.ghostTap = true;
	}

    public static function resetBinds():Void{

        controls.data.upBind = "W";
        controls.data.downBind = "S";
        controls.data.leftBind = "A";
        controls.data.rightBind = "D";
        controls.data.killBind = "R";
        controls.data.gpupBind = "DPAD_UP";
        controls.data.gpdownBind = "DPAD_DOWN";
        controls.data.gpleftBind = "DPAD_LEFT";
        controls.data.gprightBind = "DPAD_RIGHT";
        PlayerSettings.player1.controls.loadKeyBinds();

	}

    public static function keyCheck():Void
    {
        if(controls.data.upBind == null){
            controls.data.upBind = "W";
            trace("No UP");
        }
        if (StringTools.contains(controls.data.upBind,"NUMPAD"))
            controls.data.upBind = "W";
        if(controls.data.downBind == null){
            controls.data.downBind = "S";
            trace("No DOWN");
        }
        if (StringTools.contains(controls.data.downBind,"NUMPAD"))
            controls.data.downBind = "S";
        if(controls.data.leftBind == null){
            controls.data.leftBind = "A";
            trace("No LEFT");
        }
        if (StringTools.contains(controls.data.leftBind,"NUMPAD"))
            controls.data.leftBind = "A";
        if(controls.data.rightBind == null){
            controls.data.rightBind = "D";
            trace("No RIGHT");
        }
        if (StringTools.contains(controls.data.rightBind,"NUMPAD"))
            controls.data.rightBind = "D";
        
        if(controls.data.gpupBind == null){
            controls.data.gpupBind = "DPAD_UP";
            trace("No GUP");
        }
        if(controls.data.gpdownBind == null){
            controls.data.gpdownBind = "DPAD_DOWN";
            trace("No GDOWN");
        }
        if(controls.data.gpleftBind == null){
            controls.data.gpleftBind = "DPAD_LEFT";
            trace("No GLEFT");
        }
        if(controls.data.gprightBind == null){
            controls.data.gprightBind = "DPAD_RIGHT";
            trace("No GRIGHT");
        }

        trace('KEYBINDS: ${controls.data.leftBind}-${controls.data.downBind}-${controls.data.upBind}-${controls.data.rightBind}.');
    }

	public static function bind():Void
	{
		trace("Creating/reconnecting data!");

		#if (flixel < "5.0.0") //fuck you sanco // bro i cant even compile to 4.11.0
		other.bind('other');
		settings.bind('settings');
		controls.bind('controls');
		#else
		other.bind('other', 'funkergarten');
		settings.bind('settings', 'funkergarten');
		controls.bind('controls', 'funkergarten');
		#end
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