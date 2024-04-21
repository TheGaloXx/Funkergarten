package substates;

import options.OptionsMenu;
import funkin.MusicBeatState;
import states.PlayState;
import flixel.FlxCamera;
import objects.KinderButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import data.GlobalData;

class PauseSubState extends funkin.MusicBeatSubstate
{
	private var pauseMusic:flixel.sound.FlxSound;
	private var camHUD:FlxCamera;

	public static var options:Bool = false;

	var canDoSomething:Bool = true;

	public function new()
	{
		super();

		CoolUtil.title('Paused');
		CoolUtil.presence(null, Language.get('Discord_Presence', 'pause_menu'), false, 0, null);

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.zoom = 0.8;
		FlxG.cameras.add(camHUD, false);

		pauseMusic = new flixel.sound.FlxSound().loadEmbedded(Paths.music('breakfast', 'shared'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play();
		pauseMusic.fadeIn(2, 0, 0.75);
		FlxG.sound.list.add(pauseMusic);

		var bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width * 2, FlxG.height * 2);
        bg.updateHitbox();
		bg.alpha = 0.75;
		bg.scrollFactor.set();
		bg.screenCenter();
		bg.cameras = [camHUD];
		add(bg);

		var page = new FlxSprite().loadGraphic(Paths.image('pausePage', 'preload'));
        page.screenCenter();
        page.active = false;
		page.scrollFactor.set();
		page.cameras = [camHUD];
        add(page);

		var menuItems:Array<String> = [
			Language.get('PauseScreen', 'resume'),
			Language.get('PauseScreen', 'restart'),
			Language.get('PauseScreen', 'botplay_${GlobalData.botplay}'),
			Language.get('PauseScreen', 'practice_${GlobalData.practice}'),
			Language.get('PauseScreen', 'options'),
			Language.get('PauseScreen', 'exit'),
		];

		for (i in 0...menuItems.length)
		{
			var daOption:SwagOptions = null;
			switch(i)
			{
				case 0: daOption = RESUME;
				case 1: daOption = RESTART;
				case 2: daOption = BOTPLAY;
				case 3: daOption = PRACTICE;
				case 4: daOption = OPTIONS;
				case 5: daOption = EXIT;
			}

			var option:KinderButton = new KinderButton(0, page.y + 100 + (55 * i), menuItems[i], false);
			option.screenCenter(X);
			option.cameras = [camHUD];
			option.callback = () -> goToState(daOption);
        	add(option);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		@:privateAccess
		{
			final vocals = PlayState.instance.vocals;
			final inst = PlayState.instance.inst;

			if (vocals != null && inst != null)
			{
				if (!vocals._paused || !inst._paused)
				{
					vocals.pause();
					inst.pause();
				}
			}
		}

		#if debug
		if (FlxG.mouse.wheel != 0)
			FlxG.camera.zoom += (FlxG.mouse.wheel / 10);
		#end
	}

	private function goToState(option:SwagOptions)
	{
		if (!canDoSomething) return;
		canDoSomething = false;

		if (option != PRACTICE)
		{
			pauseMusic.fadeTween.cancel();
			pauseMusic.fadeTween.destroy();
			pauseMusic.stop();
			FlxG.sound.list.remove(pauseMusic);
			pauseMusic.destroy();
		}

		switch (option)
		{
			case RESUME:
				close();
			case RESTART:
				MusicBeatState.switchState(new states.PlayState());
			case BOTPLAY:
				GlobalData.botplay = !GlobalData.botplay;
				MusicBeatState.switchState(new states.PlayState());
			case PRACTICE:
				GlobalData.practice = !GlobalData.practice;
				MusicBeatState.switchState(new states.PlayState());
			case OPTIONS:
				options = true;
				funkin.MusicBeatState.switchState(new OptionsMenu(MAIN));
			case EXIT:
				FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), 0.7);
				funkin.Conductor.changeBPM(91 * 2);

				funkin.MusicBeatState.switchState(states.PlayState.isStoryMode ? new states.MainMenuState() : new states.FreeplayState());
		}
	}
}

enum SwagOptions
{
	RESUME;
	RESTART;
	BOTPLAY;
	PRACTICE;
	OPTIONS;
	EXIT;
}