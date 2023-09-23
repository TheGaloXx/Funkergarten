package states;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

//using StringTools;

class TitleState extends funkin.MusicBeatState
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
	var bucket:FlxSprite;

	var screen:FlxSprite;
	
	function startIntro()
	{
		final tex = Paths.getSparrowAtlas('menu/title_assets', 'preload');

		FlxG.camera.fade(FlxColor.BLACK, 1, true, function() 
			{
				canPressSomething = true;
			});

		FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), 0);

		FlxG.sound.music.fadeIn(4, 0, 0.7 * data.KadeEngineData.settings.data.musicVolume);

		funkin.Conductor.changeBPM(91 * 2);

		var bg = new FlxSprite();
		bg.frames = tex;
		bg.animation.addByPrefix('idle', 'bg', 0, false);
		bg.animation.play('idle');
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		bg.active = false;
		add(bg);

		logo = new FlxSprite(0, 0).loadGraphic(Paths.image('menu/logo', 'preload'));
		logo.screenCenter(X);
		add(logo);

		bf = new FlxSprite();
		bf.frames = tex;
		bf.animation.addByPrefix('idle', 'bf', 0, false);
		bf.animation.play('idle');
		bf.updateHitbox();
		bf.setPosition(FlxG.width + 600, FlxG.height - bf.height);
		add(bf);
		FlxTween.tween(bf, {x: FlxG.width - bf.width + 25}, 1, {ease: FlxEase.sineOut});
		
		protagonist = new FlxSprite();
		protagonist.frames = tex;
		protagonist.animation.addByPrefix('idle', 'protagonist', 0, false);
		protagonist.animation.play('idle');
		protagonist.updateHitbox();
		protagonist.setPosition(-600, FlxG.height - protagonist.height);
		add(protagonist);
		FlxTween.tween(protagonist, {x: 0}, 1, {ease: FlxEase.sineOut, onComplete: function(_) CoolUtil.sound('yay', 'preload', 0.3)});

		bucket = new FlxSprite(0, FlxG.height);
		bucket.frames = tex;
		bucket.animation.addByPrefix('idle', 'bucket', 0, false);
		bucket.animation.play('idle');
		bucket.updateHitbox();
		bucket.screenCenter(X);
		add(bucket);
		FlxTween.tween(bucket, {y: FlxG.height - bucket.height}, 1, {ease: FlxEase.sineOut});
		// CoolUtil.glow(bucket);

		var thingy:FlxSprite = new FlxSprite().makeGraphic(1,1, FlxColor.BLACK);
		thingy.alpha = 0.35;
		add(thingy);

		screen = new FlxSprite();
		screen.frames = Paths.getSparrowAtlas('menu/screen', 'preload');
		screen.animation.addByIndices('fullUnselected', 'fullscreen', [0, 1], "", 6, true);
		screen.animation.addByIndices('fullSelected', 'fullscreen', [2, 3], "", 6, true);
		screen.animation.addByIndices('windowUnselected', 'windowed', [0, 1], "", 6, true);
		screen.animation.addByIndices('windowSelected', 'windowed', [2, 3], "", 6, true);
		screen.animation.play((data.KadeEngineData.settings.data.fullscreen ? 'windowUnselected' : 'fullUnselected'));
		screen.setPosition(FlxG.width - screen.width - 10, FlxG.height - screen.height - 10);
		add(screen);

		thingy.setGraphicSize(Std.int(screen.width), Std.int(screen.height));
		thingy.updateHitbox();
		thingy.setPosition(screen.x, screen.y);

		// 0 = el piso de la ventana
		// flxg.height = el techo de la ventana
		//no pelotudo es al reves

		logo.y = logo.height - 400;

		#if debug
		data.KadeEngineData.settings.data.language = null;
		#end
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			funkin.Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (screen != null)
			{
				if (data.KadeEngineData.settings.data.fullscreen)
					{
						if (CoolUtil.overlaps(screen))
								screen.animation.play('windowSelected');
						else
								screen.animation.play('windowUnselected');
					}
				else
					{
						if (CoolUtil.overlaps(screen))
								screen.animation.play('fullSelected');
						else
								screen.animation.play('fullUnselected');
					}
		
				if (CoolUtil.overlaps(screen))
					{
						if (FlxG.mouse.justPressed && canPressSomething)
							{
								canPressSomething = false;
								data.KadeEngineData.settings.data.fullscreen = !data.KadeEngineData.settings.data.fullscreen;
								FlxG.fullscreen = data.KadeEngineData.settings.data.fullscreen;
		
								new FlxTimer().start(1, function(_)
									{
										canPressSomething = true;
									});
							}
					}
			}


		//if (controls.ACCEPT && canPressSomething)
		if ((controls.ACCEPT || FlxG.mouse.justPressed) && canPressSomething)
		{
			canPressSomething = false;

			FlxTween.tween(protagonist, {x: -600}, 1, {ease: FlxEase.sineIn});
			FlxTween.tween(bf, {x: FlxG.width + 575}, 1, {ease: FlxEase.sineIn});
			FlxTween.tween(bucket, {y: FlxG.height}, 1, {ease: FlxEase.sineOut});

			if (data.KadeEngineData.settings.data.flashing)
				FlxG.camera.fade(FlxColor.BLACK, 1, false);

			CoolUtil.sound('confirmMenu', 'preload', 0.7);

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if (data.KadeEngineData.settings.data.language == null)
					funkin.MusicBeatState.switchState(new LanguageState());
				else
				{
					Language.populate();
					substates.LoadShared.initial(new states.MainMenuState());
				}
			});
		}

		super.update(elapsed);
	}
}
