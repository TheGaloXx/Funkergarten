package substates;

import flixel.FlxCamera;
import objects.Objects.KinderButton;
import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends funkin.MusicBeatSubstate
{
	var curSelected:Int = 0;

	private var pauseMusic:flixel.sound.FlxSound;
	private var camHUD:FlxCamera;

	public static var options:Bool = false;
	public static var time:Float;

	var canDoSomething:Bool = true;

	public function new()
	{
		super();

		CoolUtil.title('Paused');
		CoolUtil.presence(null, 'Paused', false, 0, null);

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.zoom = 0.8;
		FlxG.cameras.add(camHUD, false);

		pauseMusic = new flixel.sound.FlxSound().loadEmbedded(Paths.music('breakfast', 'shared'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play();
		pauseMusic.fadeIn(2, 0, 0.75);
		FlxG.sound.list.add(pauseMusic);

		var bg = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
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
			Language.get('PauseScreen', 'botplay_${data.KadeEngineData.botplay}'),
			Language.get('PauseScreen', 'practice_${data.KadeEngineData.practice}'),
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

			var option:KinderButton = null;
        	add(option = new KinderButton(0, page.y + 100 + (55 * i), menuItems[i], null, function() goToState(daOption), false));
			option.cameras = [camHUD];
			option.screenCenter(X);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

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
				states.PlayState.SONG.speed = states.PlayState.originalSongSpeed;
				LoadingState.loadAndSwitchState(new states.PlayState());
			case BOTPLAY:
				data.KadeEngineData.botplay = !data.KadeEngineData.botplay;
				states.PlayState.SONG.speed = states.PlayState.originalSongSpeed;
				LoadingState.loadAndSwitchState(new states.PlayState());
			case PRACTICE:
				if (states.PlayState.storyDifficulty == 3)
					pussyAlert(); //scrapped :broken_heart:
				else
				{
					data.KadeEngineData.practice = !data.KadeEngineData.practice;
					states.PlayState.SONG.speed = states.PlayState.originalSongSpeed;	
					LoadingState.loadAndSwitchState(new states.PlayState());
				}
			case OPTIONS:
				options = true;
				states.PlayState.SONG.speed = states.PlayState.originalSongSpeed;
				funkin.MusicBeatState.switchState(new options.KindergartenOptions(null));
			case EXIT:
				states.PlayState.SONG.speed = states.PlayState.originalSongSpeed;
				funkin.MusicBeatState.switchState(new states.MainMenuState());
		}
	}



	// idk if its used anymore but gonna do it just in case - no it was scrapped
	function pussyAlert():Void
		{
			if (canDoSomething)
				canDoSomething = false;

			var quotes:Array<String> = [];

			// from cool util dialogue loading
			var langQuotes:haxe.DynamicAccess<Dynamic> = Language.getSection('Quotes_SkillIssue');
			for (idx => val in langQuotes)
			{
				quotes[Std.parseInt(idx)] = val;
			}
		
			CoolUtil.sound('ohHellNo', 'shared');

			new FlxTimer().start(0.55, function(tmr:FlxTimer)
			{
				//copypasted from creditsmenu lol
				var dumb:FlxSprite = new FlxSprite(0,0).makeGraphic(Std.int(FlxG.width * 0.6 + 50), Std.int(FlxG.height * 0.7), FlxColor.BLACK);
				dumb.alpha = 0.65;
				dumb.screenCenter();
				dumb.acceleration.y = FlxG.random.int(400, 500);
				add(dumb);

				var text:FlxText = new FlxText(0,0,0, quotes[FlxG.random.int(0, quotes.length - 1)], 80);
				text.scrollFactor.set();
				text.setFormat(null, 90, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				text.borderSize = 8;
				text.screenCenter();
				add(text);

				FlxTween.tween(dumb, {alpha: 0, angle: FlxG.random.float(2.5, -2.5)}, 1, {startDelay: 0.2, ease: FlxEase.expoOut});
				FlxTween.tween(text, {alpha: 0, angle: FlxG.random.int(5, -5), y: 375}, 1, {startDelay: 0.2, ease: FlxEase.expoOut, onComplete: function(_)
				{
					dumb.kill();
					text.kill();

					if (!canDoSomething)
						canDoSomething = true;
				}});
			});
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