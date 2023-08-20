package funkin;

import funkin.Conductor.BPMChangeEvent;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	public function new(BGColor:flixel.util.FlxColor = flixel.util.FlxColor.TRANSPARENT)
	{
		super(BGColor);
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):data.Controls;

	inline function get_controls():data.Controls
		return data.PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		flixel.FlxG.watch.addQuick("curBeat:", curBeat);
		flixel.FlxG.watch.addQuick("curStep", curStep);

		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();


		super.update(elapsed);
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
			if (funkin.Conductor.songPosition > funkin.Conductor.bpmChangeMap[i].songTime)
				lastChange = funkin.Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((funkin.Conductor.songPosition - lastChange.songTime) / funkin.Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
