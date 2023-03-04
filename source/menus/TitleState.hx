package menus;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

//using StringTools;

class TitleState extends MusicBeatState
{
	var canPressSomething:Bool = false;

	override public function create():Void
	{	
		CoolUtil.title("Main Menu");
		CoolUtil.presence(null, 'Main Menu', false, 0, null);

		#if debug 
		FlxG.sound.volumeUpKeys = [Q, PLUS];
		#end
		/*codigo epico para las teclas del volumen que quiza use despues
		var volumeUp:FlxKey = FlxG.keys.firstPressed();
		FlxG.sound.volumeUpKeys = [PLUS, volumeUp];
		*/

		FlxG.game.focusLostFramerate = 60;

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});

		super.create();
	}

	var logo:FlxSprite;

	var bf:FlxSprite;
	var protagonist:FlxSprite;

	var titleText:FlxSprite;
	var screen:FlxSprite;
	
	function startIntro()
	{
		FlxG.camera.fade(FlxColor.BLACK, 1, true, function() 
			{
				canPressSomething = true;
			});

		FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), 0);

		FlxG.sound.music.fadeIn(4, 0, 0.7 * FlxG.save.data.musicVolume);

		Conductor.changeBPM(130);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		logo = new FlxSprite(0, 0).loadGraphic(Paths.image('menu/logo'));
		logo.antialiasing = FlxG.save.data.antialiasing;
		logo.setGraphicSize(Std.int(logo.width * 0.6));
		logo.updateHitbox();
		logo.screenCenter(X);
		add(logo);

		bf = new FlxSprite().loadGraphic(Paths.image('menu/menu_bf'));
		bf.setGraphicSize(Std.int(bf.width * 0.8));
		bf.updateHitbox();
		bf.antialiasing = FlxG.save.data.antialiasing;
		bf.setPosition(FlxG.width + 600, FlxG.height - bf.height);
		add(bf);
		FlxTween.tween(bf, {x: FlxG.width - bf.width + 25}, 1, {ease: FlxEase.sineOut});
		
		protagonist = new FlxSprite().loadGraphic(Paths.image('menu/menu_protagonist'));
		protagonist.setGraphicSize(Std.int(protagonist.width * 0.9));
		protagonist.updateHitbox();
		protagonist.antialiasing = FlxG.save.data.antialiasing;
		protagonist.setPosition(-600, FlxG.height - protagonist.height);
		add(protagonist);
		FlxTween.tween(protagonist, {x: 0}, 1, {ease: FlxEase.sineOut});

		titleText = new FlxSprite(10, FlxG.height * 0.8 - 50);
		titleText.frames = Paths.getSparrowAtlas('menu/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = FlxG.save.data.antialiasing;
		titleText.setGraphicSize(Std.int(titleText.width * 0.7));
		titleText.updateHitbox();
		titleText.screenCenter(X);
		titleText.x += 175;
		titleText.animation.play('idle');
		// titleText.screenCenter(X);
		add(titleText);

		var thingy:FlxSprite = new FlxSprite().makeGraphic(1,1, FlxColor.BLACK);
		thingy.alpha = 0.35;
		add(thingy);

		screen = new FlxSprite();
		screen.frames = Paths.getSparrowAtlas('menu/screen');
		screen.antialiasing = FlxG.save.data.antialiasing;
		screen.animation.addByIndices('fullUnselected', 'fullscreen', [0, 1], "", 6, true);
		screen.animation.addByIndices('fullSelected', 'fullscreen', [2, 3], "", 6, true);
		screen.animation.addByIndices('windowUnselected', 'windowed', [0, 1], "", 6, true);
		screen.animation.addByIndices('windowSelected', 'windowed', [2, 3], "", 6, true);
		screen.animation.play((FlxG.save.data.fullscreen ? 'windowUnselected' : 'fullUnselected'));
		screen.setPosition(FlxG.width - screen.width - 10, FlxG.height - screen.height - 10);
		add(screen);

		thingy.setGraphicSize(Std.int(screen.width), Std.int(screen.height));
		thingy.updateHitbox();
		thingy.setPosition(screen.x, screen.y);

		// 0 = el piso de la ventana
		// flxg.height = el techo de la ventana
		//no pelotudo es al reves

		logo.y = logo.height - 400;

		FlxG.mouse.visible = true;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (screen != null)
			{
				if (FlxG.save.data.fullscreen)
					{
						if (FlxG.mouse.overlaps(screen))
								screen.animation.play('windowSelected');
						else
								screen.animation.play('windowUnselected');
					}
				else
					{
						if (FlxG.mouse.overlaps(screen))
								screen.animation.play('fullSelected');
						else
								screen.animation.play('fullUnselected');
					}
		
				if (FlxG.mouse.overlaps(screen))
					{
						if (FlxG.mouse.justPressed && canPressSomething)
							{
								canPressSomething = false;
								FlxG.save.data.fullscreen = !FlxG.save.data.fullscreen;
		
								new FlxTimer().start(1, function(_)
									{
										canPressSomething = true;
									});
							}
					}
			}
		
		FlxG.fullscreen = FlxG.save.data.fullscreen;

		var pressedEnter:Bool = controls.ACCEPT;

		if (pressedEnter && canPressSomething)
		{
			canPressSomething = false;

			FlxTween.tween(protagonist, {x: -600}, 1, {ease: FlxEase.sineIn});
			FlxTween.tween(bf, {x: FlxG.width + 575}, 1, {ease: FlxEase.sineIn});

			if (FlxG.save.data.flashing)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1, false);
				titleText.animation.play('press');
			}

			CoolUtil.sound('confirmMenu', 'preload', 0.7);

			MainMenuState.firstStart = true;

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxG.mouse.visible = false;

				if (FlxG.save.data.esp == null)
					MusicBeatState.switchState(new AdviceState());
				else
					substates.LoadShared.initial(new menus.MainMenuState());
			});
		}

		super.update(elapsed);
	}
}
