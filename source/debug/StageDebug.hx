package debug;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;

using StringTools;

class StageDebug extends funkin.MusicBeatState
{
    var stage:objects.Stage;
    var gf:objects.GF;
	var dad:objects.Character;
	var bf:objects.Character;
	var camFollow:FlxObject;

	override function create()
	{
        FlxG.camera.zoom -= 0.5;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0, 0); //gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

        stage = new objects.Stage();
        add(stage);

        gf = objects.GF.newGF(stage);
		add(gf);

		dad = new objects.Character(stage.positions['dad'][0], stage.positions['dad'][1], states.PlayState.dad.curCharacter);
		dad.debugMode = true;
		add(dad);

		dad.flipX = false;

		bf = new objects.Character(stage.positions['bf'][0], stage.positions['bf'][1], states.PlayState.boyfriend.curCharacter, true);
		bf.debugMode = true;
		add(bf);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
			funkin.MusicBeatState.switchState(new states.PlayState());

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		super.update(elapsed);
	}
}