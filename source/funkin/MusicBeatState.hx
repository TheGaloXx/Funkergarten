package funkin;

import flixel.FlxState;
import funkin.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var daSection:funkin.Section.SwagSection = null; // holy shit dont name this "curSection"
	private var controls(get, never):data.Controls;

	inline function get_controls():data.Controls
		return data.PlayerSettings.player1.controls;

	override function create()
	{
		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new substates.CustomFadeTransition(0.7, true));

		FlxTransitionableState.skipNextTransOut = false;
		
		Main.changeFPS(data.KadeEngineData.settings.data.fpsCap);

		super.create();
	}

	override function update(elapsed:Float)
	{
		FlxG.watch.addQuick("curBeat:", curBeat);
		FlxG.watch.addQuick("curStep", curStep);

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
		for (i in 0...funkin.Conductor.bpmChangeMap.length)
		{
			if (funkin.Conductor.songPosition >= funkin.Conductor.bpmChangeMap[i].songTime)
				lastChange = funkin.Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((funkin.Conductor.songPosition - lastChange.songTime) / funkin.Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0) beatHit();
		if (curStep % 16 == 0) sectionHit(); //why not?
	}

	public function beatHit():Void {} //do literally nothing dumbass
	public function sectionHit():Void 
	{
		if (states.PlayState.SONG != null)
			if (states.PlayState.SONG.notes != null)
				if (states.PlayState.SONG.notes[Std.int(curStep / 16)] != null)
					daSection = states.PlayState.SONG.notes[Std.int(curStep / 16)];
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
		var leState:funkin.MusicBeatState = curState;
		if (!FlxTransitionableState.skipNextTransIn)
		{
			leState.openSubState(new substates.CustomFadeTransition(0.6, false));
			if (nextState == FlxG.state)
			{
				substates.CustomFadeTransition.finishCallback = function()
				{
					FlxG.resetState();
				};
			}
			else
			{
				substates.CustomFadeTransition.finishCallback = function()
				{
					FlxG.switchState(nextState);
				};
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public function secretSong(song:String, difficulty:Int)
	{
		if (difficulty > 2)
			difficulty = 2;
		if (difficulty < 0)
			difficulty = 0;
		
		var poop:String = data.Highscore.formatSong(song, difficulty);
		
		states.PlayState.SONG = funkin.Song.loadFromJson(poop, song, true);
		states.PlayState.storyDifficulty = difficulty;
		states.PlayState.scoreData.sicks = 0;
		states.PlayState.scoreData.bads = 0;
		states.PlayState.scoreData.shits = 0;
		states.PlayState.scoreData.goods = 0;
		states.PlayState.tries = 0;
		
		substates.LoadingState.loadAndSwitchState(new states.PlayState(), true);
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
			case STEPS:    funkin.Conductor.stepCrochet / 1000;
			case BEATS:    funkin.Conductor.crochet / 1000;
			case SECTIONS: (funkin.Conductor.stepCrochet / 1000) * 16;
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