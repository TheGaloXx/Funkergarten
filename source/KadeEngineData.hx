import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
import flixel.FlxG;

class KadeEngineData
{
    public static function initSave()
    {
		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;
			
		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = true;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		if (FlxG.save.data.fpsCap > 285 || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 120; //baby proof so you can't hard lock ur copy of kade engine
		
		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.compiles == null)
			FlxG.save.data.compiles = 0;

		if (FlxG.save.data.mondays == null)
			FlxG.save.data.mondays = 0;

		if (FlxG.save.data.gotCardDEMO == null)
			FlxG.save.data.gotCardDEMO = false;

		if (FlxG.save.data.tries == null)
			FlxG.save.data.tries = 0;

		if (FlxG.save.data.mechanics == null)
			FlxG.save.data.mechanics == true;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.antialiasing == null)
			FlxG.save.data.antialiasing = true;

		if (FlxG.save.data.showHelp == null)
			FlxG.save.data.showHelp == true;

		if (FlxG.save.data.esp == null)
			FlxG.save.data.esp = false;

		if (FlxG.save.data.camMove == null)
			FlxG.save.data.camMove = true;

		if (FlxG.save.data.snap == null)
			FlxG.save.data.snap = false;

		if (FlxG.save.data.fullscreen == null)
			FlxG.save.data.fullscreen = false;

		if (FlxG.save.data.practice == null)
			FlxG.save.data.practice = false;

		if (FlxG.save.data.middlescroll == null)
			FlxG.save.data.middlescroll = false;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.shaders == null)
			FlxG.save.data.shaders = true;
		
		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.scoreScreen == null)
			FlxG.save.data.scoreScreen = true;

		if (FlxG.save.data.musicVolume == null)
			FlxG.save.data.musicVolume = 1;

		if (FlxG.save.data.soundVolume == null)
			FlxG.save.data.soundVolume = 1;

		if (FlxG.save.data.lockSong == null)
			FlxG.save.data.lockSong = true;

		if (FlxG.save.data.showCharacters == null)
			FlxG.save.data.showCharacters = ['protagonist'];

		flixel.FlxSprite.defaultAntialiasing = FlxG.save.data.antialiasing;
		
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
		KeyBinds.gamepad = gamepad != null;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		FlxG.drawFramerate = FlxG.updateFramerate = FlxG.save.data.fpsCap;
	}

	public static function resetData()
		{	
			#if debug return; #end //	hehe
			FlxG.save.data.mondays = 0;
			FlxG.save.data.showCharacters = ['protagonist'];
			FlxG.save.data.gotCardDEMO = false;
		}
}