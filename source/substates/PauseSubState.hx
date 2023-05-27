package substates;

import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	
	var menuItems:Array<String> = [
		Language.get('PauseScreen', 'resume'),
		Language.get('PauseScreen', 'restart'),
		Language.get('PauseScreen', 'botplay_${KadeEngineData.botplay}'),
		Language.get('PauseScreen', 'practice_${KadeEngineData.practice}'),
		Language.get('PauseScreen', 'options'),
		Language.get('PauseScreen', 'exit'),
	];
	var curSelected:Int = 0;

	var pauseMusic:flixel.system.FlxSound;
	public static var options:Bool = false;

	public static var time:Float;

	var canDoSomething:Bool = true;

	public function new()
	{
		super();

		CoolUtil.title('Paused');
		CoolUtil.presence(null, 'Paused', false, 0, null);

		if (pauseMusic != null)
			pauseMusic.kill();
		pauseMusic = new flixel.system.FlxSound().loadEmbedded(Paths.music('breakfast', 'shared'), true, true);
		pauseMusic.volume = 0;
		if (pauseMusic == null)
			add(pauseMusic);
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxTween.tween(pauseMusic, {volume: 0.75 * KadeEngineData.settings.data.musicVolume}, 2);

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.3, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (60 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		var soundShit:SoundSetting = new SoundSetting(true);
		add(soundShit);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;

		if (gamepad != null && KeyBinds.gamepad)
		{
			upP = gamepad.justPressed.DPAD_UP;
			downP = gamepad.justPressed.DPAD_DOWN;
			leftP = gamepad.justPressed.DPAD_LEFT;
			rightP = gamepad.justPressed.DPAD_RIGHT;
		}

		if (upP)
			changeSelection(-1);
		else if (downP)
			changeSelection(1);

		if (accepted && canDoSomething)
		{
			canDoSomething = false;

			var daSelected:String = menuItems[curSelected];

			pauseMusic.kill();

			switch (daSelected)
			{
				case "Resume" | "Resumir":

					var startTimer:FlxTimer;
					
					var swagCounter:Int = 0;

					startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
					{
							var sprites = ['ready', 'set', 'go'];
							var suffix:String = (PlayState.isPixel ? "-pixel" : "");
							var pixelFolder = (PlayState.isPixel ? 'pixel/' : '');
		
							if (swagCounter > 0)
							{
								var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameplay/' + pixelFolder + sprites[swagCounter - 1], 'shared'));
								spr.scrollFactor.set();
								if (PlayState.isPixel && sprites[swagCounter - 1] != 'go'){
									spr.antialiasing = false;
									spr.setGraphicSize(Std.int(spr.width * 6));
								}
								spr.updateHitbox();
								spr.screenCenter();
								add(spr);
		
								FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										spr.destroy();
									}
								});
							}
		
							var daSound:String = null;
		
							switch (swagCounter)
							{
								case 0:	daSound = '3';
								case 1: daSound = '2';
								case 2: daSound = '1';
								case 3: daSound = 'Go';
								case 4: close();
								case 5: daSound = null;
							}
		
							if (daSound != null)
								CoolUtil.sound('intro' + daSound + suffix, 'shared', 0.6);
		
							swagCounter += 1;
						}, 5);

				case "Restart song" | "Reiniciar cancion":
					PlayState.SONG.speed = PlayState.originalSongSpeed;
					LoadingState.loadAndSwitchState(new PlayState());
				case "Enable botplay" | "Disable botplay" | "Activar botplay" | "Desactivar botplay":
					KadeEngineData.botplay = !KadeEngineData.botplay;
					
					PlayState.SONG.speed = PlayState.originalSongSpeed;
					
					LoadingState.loadAndSwitchState(new PlayState());
				case "Enable practice mode" | "Disable practice mode" | "Activar modo de practica" | "Desactivar modo de practica":
					if (PlayState.storyDifficulty == 3)
						{
							pussyAlert();
						}
					else
						{
							if (KadeEngineData.practice)
								KadeEngineData.practice = false;
							else
								KadeEngineData.practice = true;
							PlayState.SONG.speed = PlayState.originalSongSpeed;
							
							LoadingState.loadAndSwitchState(new PlayState());
						}
				case "Options" | "Opciones":	
					options = true;
					
					PlayState.SONG.speed = PlayState.originalSongSpeed;
					MusicBeatState.switchState(new options.KindergartenOptions());
				case "Exit to menu" | "Regresar al menu":				
					PlayState.SONG.speed = PlayState.originalSongSpeed;

					MusicBeatState.switchState(new menus.MainMenuState());
			}
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		if (!canDoSomething)
			return;

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}

	// idk if its used anymore but gonna do it just in case
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