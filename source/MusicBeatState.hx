package;

import flixel.FlxState;
import Shaders.ChromaHandler;
import openfl.filters.ShaderFilter;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var daSection:Section.SwagSection = null; // holy shit dont name this "curSection"
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new CustomFadeTransition(0.7, true));

		FlxTransitionableState.skipNextTransOut = false;

		setChrome(0);
		
		Main.changeFPS(KadeEngineData.settings.data.fpsCap);

		super.create();
	}

	override function update(elapsed:Float)
	{
		FlxG.watch.addQuick('BPM:', Conductor.bpm);
		FlxG.watch.addQuick('CROCHET:', Conductor.crochet);
		FlxG.watch.addQuick('STEP CROCHET:', Conductor.stepCrochet);

		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curStep;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0) beatHit();
		if (curStep % 16 == 0) sectionHit(); //why not?
	}

	public function beatHit():Void {} //do literally nothing dumbass
	public function sectionHit():Void 
	{
		if (PlayState.SONG != null)
			if (PlayState.SONG.notes != null)
				if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
					daSection = PlayState.SONG.notes[Std.int(curStep / 16)];
	}
	
	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}

	public static function switchState(nextState:FlxState)
	{
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if (!FlxTransitionableState.skipNextTransIn)
		{
			leState.openSubState(new CustomFadeTransition(0.6, false));
			if (nextState == FlxG.state)
			{
				CustomFadeTransition.finishCallback = function()
				{
					FlxG.resetState();
				};
			}
			else
			{
				CustomFadeTransition.finishCallback = function()
				{
					FlxG.switchState(nextState);
				};
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}
	
	// CHROMATIC SHADER
	public var chromaticAberration(get, never):ShaderFilter;

	inline function get_chromaticAberration():ShaderFilter
		return ChromaHandler.chromaticAberration;

	public function setChrome(daChrome:Float):Void
	{
		if (!KadeEngineData.settings.data.flashing || !KadeEngineData.settings.data.shaders)
			return;

		ChromaHandler.setChrome(daChrome);
	}

	public function secretSong(song:String, difficulty:Int)
	{
		if (difficulty > 2)
			difficulty = 2;
		if (difficulty < 0)
			difficulty = 0;
		
		var poop:String = Highscore.formatSong(song, difficulty);
		
		PlayState.SONG = Song.loadFromJson(poop, song, true);
		PlayState.storyDifficulty = difficulty;
		PlayState.sicks = 0;
		PlayState.bads = 0;
		PlayState.shits = 0;
		PlayState.goods = 0;
		PlayState.tries = 0;
		
		substates.LoadingState.loadAndSwitchState(new PlayState(), true);
	}

	/**
	 * Function that returns time in seconds based on conductor's shit.
	 * @param   value   	 The value to base the time in. (`STEPS`, `BEATS` OR `SECTIONS`).
	 * @param   howMany   	 The number of times the value will be multiplied.
	**/

	public function getTimeFromBeats(value:FlxBeats, howMany:Float = 1):Float
	{
		var time:Float = switch (value)
		{
			case STEPS:    Conductor.stepCrochet / 1000;
			case BEATS:    Conductor.crochet / 1000;
			case SECTIONS: (Conductor.stepCrochet / 1000) * 16;
		}
		time *= howMany;
		
		trace('Getting time from music shit, [ $value - value: $howMany - time: ${flixel.math.FlxMath.roundDecimal(time, 2)} ].');
	
		if (time > 0)
			return time;
		else
			trace("You're an idiot lmfao.");

		return 0;
	}
}

enum FlxBeats
{
   STEPS;
   BEATS;
   SECTIONS;
}