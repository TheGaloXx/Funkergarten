package funkin;

import data.Highscore;
import data.GlobalData;
import data.PlayerSettings;
import data.Controls;
import funkin.Section.SwagSection;
import substates.CustomFadeTransition;
import states.PlayState;
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
	private var daSection:SwagSection = null; // holy shit dont name this "curSection"
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player.controls;

	override function create()
	{
		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new CustomFadeTransition(0.7, true));

		FlxTransitionableState.skipNextTransOut = false;
		
		Main.changeFPS(GlobalData.settings.fpsCap);

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

	private inline function updateBeat():Void
	{
		lastBeat = curStep;
		curBeat = Math.floor(curStep / 4);
	}

	private inline function updateCurStep():Void
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
	}

	public function beatHit():Void {} //do literally nothing dumbass

	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}

	public static function switchState(nextState:FlxState, stopMusic:Bool = false)
	{
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;

		if (!FlxTransitionableState.skipNextTransIn)
		{
			leState.openSubState(new CustomFadeTransition(0.6, false));

			CustomFadeTransition.finishCallback = function()
			{
				if (nextState == FlxG.state)
				{
					trace('TRYING TO SWITCH TO THE SAME STATE. RESETING INSTEAD!');
					FlxG.resetState();
				}
				else
					FlxG.switchState(nextState);
			};

			return;
		}

		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
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
		PlayState.scoreData.sicks = 0;
		PlayState.scoreData.bads = 0;
		PlayState.scoreData.shits = 0;
		PlayState.scoreData.goods = 0;
		PlayState.tries = 0;
		
		switchState(new PlayState(), true);
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