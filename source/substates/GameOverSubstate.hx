package substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;
	
	public function new(x:Float, y:Float)
	{
		var daBf:String = '';
		if (PlayState.boyfriend != null)
			{
				switch (PlayState.boyfriend.curCharacter)
				{
					case 'bf-pixel':
						daBf = 'bf-pixel-dead';
					default:
						daBf = 'bf-dead';
				}
			}

		CoolUtil.title('Game Over');
		CoolUtil.presence('Misses: ${PlayState.misses} - Tries: ${KadeEngineData.other.data.tries}', 'Game over', false, null, daBf, true);

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.camPos[0], bf.camPos[1], 1, 1);
		add(camFollow);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		CoolUtil.sound('fnf_loss_sfx', 'shared');
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			MusicBeatState.switchState(PlayState.isStoryMode ? new menus.MainMenuState() : new menus.FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5, {ease: flixel.tweens.FlxEase.sineOut});
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			bf.playAnim('deathLoop');
			FlxG.sound.playMusic(Paths.music('gameOver', 'shared'), KadeEngineData.settings.data.musicVolume);
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd', 'shared'), KadeEngineData.settings.data.musicVolume);
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
