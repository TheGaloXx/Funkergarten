package substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.app.Application;
import flixel.util.FlxTimer;

class JanitorDeathSubState extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;
	
	public function new(x:Float, y:Float)
	{
		Application.current.window.title = (Main.appTitle + ' - Game Over');

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
        FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5, {ease: flixel.tweens.FlxEase.sineOut});
        FlxG.camera.follow(camFollow, LOCKON, 0.01);
		bf.playAnim('firstDeath');
	}

    var canDoShit:Bool = false;
    var madeDialogue:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT && canDoShit)
		{
			endBullshit();
		}

        if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
            {
                FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5, {ease: flixel.tweens.FlxEase.sineOut});
                FlxG.camera.follow(camFollow, LOCKON, 0.01);

                if (!madeDialogue)
                {
                    madeDialogue = true;
                    new FlxTimer().start(2, function(_)
                        {
                            trace("Before dialogue created");
                            var dialogueSpr:DialogueBox = new DialogueBox(["janitor:Kids these days don't care about their accuracy."], false);
                            dialogueSpr.scrollFactor.set();
                            dialogueSpr.finishThing = ZoomIn;
                            if (dialogueSpr != null)
                                {
                                    add(dialogueSpr);
                                    trace("Added dialogue");
                                }
                        });
                }
            }

		if (controls.BACK && canDoShit)
		{
			FlxG.sound.music.stop();

			MusicBeatState.switchState(PlayState.isStoryMode ? new menus.StoryMenuState() : new menus.FreeplayState());
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
			FlxG.sound.play(Paths.music('gameOverEnd'), FlxG.save.data.musicVolume);
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}

    function ZoomIn():Void
    {
		new FlxTimer().start(0.5, function(_) //DO I REALLY HAVE TO DO THIS SO THE FUCKING MUSIC DOESNT FADE OUT BECAUSE OF THE DIALOGUE BOX END?
		{
			bf.playAnim('deathLoop');
        	FlxG.sound.playMusic(Paths.music('gameOver'), FlxG.save.data.musicVolume);

        	canDoShit = true;
		});
    }
}
