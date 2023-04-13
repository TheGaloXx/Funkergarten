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

		FlxG.sound.music.fadeIn(4, 0, 0.7 * KadeEngineData.settings.data.musicVolume);

		Conductor.changeBPM(130);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/title', 'preload'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		bg.active = false;
		trace(bg.antialiasing);
		trace(FlxSprite.defaultAntialiasing);
		trace(KadeEngineData.settings.data.antialiasing);
		add(bg);

		logo = new FlxSprite(0, 0).loadGraphic(Paths.image('menu/logo', 'preload'));
		logo.setGraphicSize(Std.int(logo.width * 0.6));
		logo.updateHitbox();
		logo.screenCenter(X);
		add(logo);

		bf = new FlxSprite().loadGraphic(Paths.image('menu/menu_bf', 'preload'));
		bf.setGraphicSize(Std.int(bf.width * 0.8));
		bf.updateHitbox();
		bf.setPosition(FlxG.width + 600, FlxG.height - bf.height);
		add(bf);
		FlxTween.tween(bf, {x: FlxG.width - bf.width + 25}, 1, {ease: FlxEase.sineOut});
		
		protagonist = new FlxSprite().loadGraphic(Paths.image('menu/menu_protagonist', 'preload'));
		protagonist.setGraphicSize(Std.int(protagonist.width * 0.9));
		protagonist.updateHitbox();
		protagonist.setPosition(-600, FlxG.height - protagonist.height);
		add(protagonist);
		FlxTween.tween(protagonist, {x: 0}, 1, {ease: FlxEase.sineOut});

		titleText = new FlxSprite(10, FlxG.height * 0.8 - 50);
		titleText.frames = Paths.getSparrowAtlas('menu/titleEnter', 'preload');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
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
		screen.frames = Paths.getSparrowAtlas('menu/screen', 'preload');
		screen.animation.addByIndices('fullUnselected', 'fullscreen', [0, 1], "", 6, true);
		screen.animation.addByIndices('fullSelected', 'fullscreen', [2, 3], "", 6, true);
		screen.animation.addByIndices('windowUnselected', 'windowed', [0, 1], "", 6, true);
		screen.animation.addByIndices('windowSelected', 'windowed', [2, 3], "", 6, true);
		screen.animation.play((KadeEngineData.settings.data.fullscreen ? 'windowUnselected' : 'fullUnselected'));
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
				if (KadeEngineData.settings.data.fullscreen)
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
								KadeEngineData.settings.data.fullscreen = !KadeEngineData.settings.data.fullscreen;
								FlxG.fullscreen = KadeEngineData.settings.data.fullscreen;
		
								new FlxTimer().start(1, function(_)
									{
										canPressSomething = true;
									});
							}
					}
			}


		//if (controls.ACCEPT && canPressSomething)
		if (FlxG.keys.justPressed.ENTER && canPressSomething)
		{
			canPressSomething = false;

			FlxTween.tween(protagonist, {x: -600}, 1, {ease: FlxEase.sineIn});
			FlxTween.tween(bf, {x: FlxG.width + 575}, 1, {ease: FlxEase.sineIn});

			if (KadeEngineData.settings.data.flashing)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1, false);
				titleText.animation.play('press');
			}

			CoolUtil.sound('confirmMenu', 'preload', 0.7);

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxG.mouse.visible = false;

				if (KadeEngineData.settings.data.esp == null)
					MusicBeatState.switchState(new AdviceState());
				else
					substates.LoadShared.initial(new menus.MainMenuState());
			});
		}

		super.update(elapsed);
	}
}
