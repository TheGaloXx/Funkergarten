package substates;

import flixel.sound.FlxSound;
import flixel.FlxG;

using StringTools;

class GameOverSubstate extends funkin.MusicBeatSubstate
{
	private var bf:objects.Boyfriend;
	private var camFollow = new flixel.FlxObject();
	private var isJanitor:Bool = states.PlayState.SONG.song == 'Staff Only';
	private var canDoShit:Bool = true;
    private var madeDialogue:Bool = false;
	private var isEnding:Bool = false;
	
	public function new(x:Float, y:Float)
	{
		super();
		canDoShit = !isJanitor;

		camFollow.screenCenter();

		CoolUtil.title('Game Over');

		final disc_misses = Language.get('Ratings', 'misses') + ' ' + states.PlayState.scoreData.misses;
		final disc_tries = Language.get('Discord_Presence', 'tries_text') + ' ' + states.PlayState.tries;

		CoolUtil.presence(disc_misses + ' - ' + disc_tries, 'Game over', false, null, states.PlayState.boyfriend.curCharacter.replace('-alt', '') + '-dead', true);

		funkin.Conductor.songPosition = 0;

		add(bf = new objects.Boyfriend(x, y, states.PlayState.boyfriend.curCharacter.replace('-alt', '') + '-dead'));

		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		CoolUtil.sound('fnf_loss_sfx', 'shared');
		funkin.Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT && canDoShit) endBullshit();
		else if (controls.BACK && canDoShit)
		{
			CoolUtil.sound('cancelMenu', 'preload', 0.5);
			canDoShit = false;
			FlxG.sound.music.stop();
			FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), 0.7);
			funkin.Conductor.changeBPM(91 * 2);
			funkin.MusicBeatState.switchState(states.PlayState.isStoryMode ? new states.MainMenuState() : new states.FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			flixel.tweens.FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5, {ease: flixel.tweens.FlxEase.sineOut});
			flixel.tweens.FlxTween.tween(camFollow, {x: bf.camPos[0], y: bf.camPos[1]}, 2, {ease: flixel.tweens.FlxEase.sineOut});

			if (isJanitor && !madeDialogue)
                {
                    madeDialogue = true;
                    new flixel.util.FlxTimer().start(2, function(_)
                        {
                            trace("Before dialogue created");
                            var dialogueSpr:objects.DialogueBox = new objects.DialogueBox([Language.get('Global', 'janitor_death')], false);
                            dialogueSpr.scrollFactor.set();
                            dialogueSpr.finishThing = function()
							{
								new flixel.util.FlxTimer().start(0.5, function(_) //DO I REALLY HAVE TO DO THIS SO THE FUCKING MUSIC DOESNT FADE OUT BECAUSE OF THE DIALOGUE BOX END?
								{
									bf.playAnim('deathLoop');
									FlxG.sound.playMusic(Paths.music('gameOver', 'shared'));
									canDoShit = true;
								});
							};
							dialogueSpr.canSkip = false;
                            if (dialogueSpr != null)
                                {
                                    add(dialogueSpr);
                                    trace("Added dialogue");
                                }

								new flixel.util.FlxTimer().start((states.PlayState.tries < 2 ? 4 : 0.1), function(_) dialogueSpr.canSkip = true);
                        });
                }
		}

		if (!isJanitor && bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			bf.playAnim('deathLoop');
			FlxG.sound.playMusic(Paths.music('gameOver', 'shared'));
		}

		if (FlxG.sound.music.playing) funkin.Conductor.songPosition = FlxG.sound.music.time;

		FlxG.camera.focusOn(camFollow.getPosition());
	}

	function endBullshit():Void
	{
		canDoShit = false;

		bf.playAnim('deathConfirm', true);
		FlxG.sound.music.stop();
	
		new FlxSound().loadEmbedded(Paths.music('gameOverEnd', 'shared'), false, true, function() LoadingState.loadAndSwitchState(new states.PlayState())).play();

		new flixel.util.FlxTimer().start(0.7, function(_) FlxG.camera.fade(flixel.util.FlxColor.BLACK, 4, false));
	}
}
