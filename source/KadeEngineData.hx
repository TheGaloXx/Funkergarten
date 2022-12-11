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

		if (FlxG.save.data.canAddShaders == null)
			FlxG.save.data.canAddShaders = true;
		
		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.scoreScreen == null)
			FlxG.save.data.scoreScreen = true;
		
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
		KeyBinds.gamepad = gamepad != null;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		(cast (Lib.current.getChildAt(0), Main)).toggleMemCounter(FlxG.save.data.fps);
	}
}