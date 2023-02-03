package menus;

import substates.LoadingState;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxBasic;
import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var startedTransition:Bool = false;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.4" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var bg:FlxBackdrop;
	var camFollow:FlxObject;

	public static var finishedFunnyMove:Bool = false;

	var character:Character;
	var logo:FlxSprite;

	override function create()
	{
		Application.current.window.title = (Main.appTitle + ' - Main Menu');

		FlxG.mouse.visible = true;

		Conductor.changeBPM(130);

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), FlxG.save.data.musicVolume);
		}

		persistentUpdate = persistentDraw = true;

		bg = new FlxBackdrop(Paths.image('menu/menuBG'), 1, 0, true, false);
		bg.x -= 200;
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter(Y);
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('menu/FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(10, FlxG.height * 1.6);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = FlxG.save.data.antialiasing;
			if (firstStart)
				FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
			else
				menuItem.y = 60 + (i * 160);
		}

		firstStart = false;

		// NG.core.calls.event.logEvent('swag').send();

		controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		logo = new FlxSprite(0, 0).loadGraphic(Paths.image('menu/logo'));
		logo.antialiasing = FlxG.save.data.antialiasing;
		logo.setGraphicSize(Std.int(logo.width * 0.3));
		logo.updateHitbox();
		logo.scrollFactor.set(0, 0);
		logo.screenCenter();
		//add(logo);

		character = new Character(0.25, 0, 'protagonist');
		character.scrollFactor.set(0, 0);
		character.setGraphicSize(Std.int(character.width * 0.5));
		character.updateHitbox();
		character.y = FlxG.height - character.height - 100;
		character.x -= 150;
		character.dance();
		//add(character);

		var blackBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 32, FlxColor.BLACK);
		blackBar.scrollFactor.set();
		blackBar.alpha = 0.5;
		add(blackBar);

		FlxTween.tween(blackBar, {alpha: 0.25}, 2, {type: PINGPONG});

		eraseText = new FlxText(0, -4, 0, (FlxG.save.data.esp ? "Manten presionada la tecla R para borrar los datos.)" : "Hold the R key to erase saved data."), 44);
		eraseText.scrollFactor.set();
		eraseText.color = FlxColor.BLACK;
        eraseText.font = Paths.font('Crayawn-v58y.ttf');
		//eraseText.screenCenter(X);
		eraseText.x = FlxG.width;
		add(eraseText);

		FlxTween.tween(eraseText, {alpha: 0.5}, 2, {type: PINGPONG});

		var soundShit:SoundSetting = new SoundSetting();
		add(soundShit);

		super.create();
	}
	var eraseText:FlxText;

	var selectedSomethin:Bool = false;
	var canHold:Bool = true;
	var time:Float = 0;

	override function update(elapsed:Float)
	{
		FlxG.watch.addQuick("Elapsed:", FlxG.elapsed);
		FlxG.watch.addQuick("Time holding R:", time);

		//erase data code
		if (FlxG.keys.pressed.R && canHold)
		{
			time += elapsed;
			if (time >= 1.25)
			{
				canHold = false;
				trace(time);
				persistentUpdate = false;
				openSubState(new substates.EraseData());
			}
		}
		else
			time = 0;

		if (FlxG.keys.justReleased.R){
			time = 0;
			canHold = true;
		}

		eraseText.x -= (200 * elapsed);
		if (eraseText.x < -600)
			eraseText.x = FlxG.width;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < (0.8 * FlxG.save.data.musicVolume))
		{
			FlxG.sound.music.volume += (0.5 * FlxG.elapsed) * FlxG.save.data.musicVolume;
		}

		if (FlxG.sound.music.volume > (0.8 * FlxG.save.data.musicVolume))
			FlxG.sound.music.volume = 0.8 * FlxG.save.data.musicVolume;

		if (!selectedSomethin)
		{
			//if (FlxG.keys.justPressed.Y && FlxG.keys.justPressed.U)
			//	{
			//		BackyardState.tellMonday = true;
			//		FlxG.switchState(new BackyardState());
			//	}
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					CoolUtil.sound('scrollMenu', 'preload');
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					CoolUtil.sound('scrollMenu', 'preload');
					changeItem(1);
				}
			}

			if (FlxG.keys.justPressed.UP)
			{
				CoolUtil.sound('scrollMenu', 'preload');
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				CoolUtil.sound('scrollMenu', 'preload');
				changeItem(1);
			}

			if (controls.BACK)
			{
				CoolUtil.sound('cancelMenu', 'preload');
				FlxG.cameras.shake(0.005, 0.25);
			}

			if (controls.ACCEPT)
			{
					selectedSomethin = true;
					CoolUtil.sound('confirmMenu', 'preload');

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {x: spr.x - 1000, alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							bg.acceleration.set(3000, 0);

							FlxTween.tween(spr, {x: spr.x + 2000}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});

							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									goToState();
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									goToState();
								});
							}
						}
					});
			}
		}

		super.update(elapsed);
	}

	override function beatHit()
		{
			if (curBeat % 2 == 0)
				{
					character.dance();
				}

			super.beatHit();
		}
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				BackyardState.tellMonday = true;
				MusicBeatState.switchState(new BackyardState());
				trace("Story Menu Selected");

			case 'freeplay':
				MusicBeatState.switchState(new FreeplayState());
				trace("Freeplay Menu Selected");

			case 'donate':
				MusicBeatState.switchState(new CreditsState());
				trace("Credits Selected");

			case 'options':
				MusicBeatState.switchState(new options.KindergartenOptions());
				trace("Options Menu Selected");
		}
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
			}

			spr.updateHitbox();
		});
	}
}
