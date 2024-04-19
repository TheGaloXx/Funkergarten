package substates;

import objects.Character;
import funkin.MusicBeatState;
import states.PlayState;
import flixel.sound.FlxSound;
import flixel.FlxG;

using StringTools;

class GameOverSubstate extends funkin.MusicBeatSubstate
{
	private var bf:objects.Character;
	private var camFollow = new flixel.FlxObject();
	private var isJanitor:Bool = states.PlayState.SONG.song == 'Staff Only';
	private var canDoShit:Bool = true;
    private var madeDialogue:Bool = false;
	private var isEnding:Bool = false;
	private var done:Bool = false;

	private var x:Float;
	private var y:Float;
	
	public function new(x:Float, y:Float, bf:Character)
	{
		super();

		this.x = x;
		this.y = y;
		this.bf = bf;
	}

	override function create()
	{
		super.create();

		FlxG.camera.angle = 0;

		canDoShit = !isJanitor;

		camFollow.screenCenter();

		CoolUtil.title('Game Over');

		final disc_misses = Language.get('Ratings', 'misses') + ' ' + states.PlayState.scoreData.misses;
		final disc_tries = Language.get('Discord_Presence', 'tries_text') + ' ' + states.PlayState.tries;

		CoolUtil.presence(disc_misses + ' - ' + disc_tries, 'Game over', false, null, states.PlayState.boyfriend.curCharacter.replace('-alt', '') + '-dead', true);

		funkin.Conductor.songPosition = 0;

		add(bf);
		bf.setPosition(x, y);

		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		CoolUtil.sound('fnf_loss_sfx', 'shared');
		funkin.Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath', true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT && canDoShit) endBullshit();
		else if (controls.BACK && canDoShit)
		{
			remove(bf);

			CoolUtil.sound('cancelMenu', 'preload', 0.5);
			canDoShit = false;
			FlxG.sound.music.stop();
			FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), 0.7);
			funkin.Conductor.changeBPM(91 * 2);
			funkin.MusicBeatState.switchState(states.PlayState.isStoryMode ? new states.MainMenuState() : new states.FreeplayState());
		}

		if (!done && bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			done = true;

			flixel.tweens.FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5, {ease: flixel.tweens.FlxEase.sineOut});
			flixel.tweens.FlxTween.tween(camFollow, {x: bf.getGraphicMidpoint().x - (bf.curCharacter == 'bf-pixel-dead' ? 125 : 0), y: bf.getGraphicMidpoint().y - (bf.curCharacter == 'bf-pixel-dead' ? 20 : 0)}, 2, {ease: flixel.tweens.FlxEase.sineOut, onUpdate: function(_) FlxG.camera.focusOn(camFollow.getPosition())});

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
									bf.playAnim('deathLoop', true);
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
			bf.playAnim('deathLoop', true);
			FlxG.sound.playMusic(Paths.music('gameOver', 'shared'));
		}

		if (FlxG.sound.music.playing) funkin.Conductor.songPosition = FlxG.sound.music.time;
	}

	function endBullshit():Void
	{
		canDoShit = false;

		bf.playAnim('deathConfirm', true);
		FlxG.sound.music.stop();
	
		new FlxSound().loadEmbedded(Paths.music('gameOverEnd', 'shared'), false, true, function()
		{
			remove(bf);
			MusicBeatState.switchState(new states.PlayState());
		}).play();

		new flixel.util.FlxTimer().start(0.7, function(_) FlxG.camera.fade(flixel.util.FlxColor.BLACK, 4, false));
	}
}
