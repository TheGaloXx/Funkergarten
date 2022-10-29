package menus;

import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import lime.app.Application;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

//using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;

	override public function create():Void
	{	
		Application.current.window.title = (Main.appTitle + ' - Title Screen');

		#if debug 
		FlxG.sound.volumeUpKeys = [Q, PLUS];
		#end

		FlxG.game.focusLostFramerate = 60;

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});

		super.create();
	}

	var logoBl:FlxSprite;
	var titleText:FlxSprite;
	var screen:FlxSprite;

	var canChange:Bool = false;
	
	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileSquare);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, -1), {asset: diamond, width: 4, height: 4},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.25, new FlxPoint(0, 1),
				{asset: diamond, width: 4, height: 4}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('menu/logoBumpin');
		logoBl.antialiasing = FlxG.save.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.screenCenter(X);
		logoBl.updateHitbox();

		add(logoBl);

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

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		FlxG.mouse.visible = true;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (screen != null && skippedIntro)
			{
				if (FlxG.save.data.fullscreen && skippedIntro)
					{
						if (FlxG.mouse.overlaps(screen))
							{
								screen.animation.play('windowSelected');
							}
						else
							{
								screen.animation.play('windowUnselected');
							}
					}
				else
					{
						if (FlxG.mouse.overlaps(screen))
							{
								screen.animation.play('fullSelected');
							}
						else
							{
								screen.animation.play('fullUnselected');
							}
					}
		
				if (FlxG.mouse.overlaps(screen))
					{
						if (FlxG.mouse.justPressed && skippedIntro && canChange && !transitioning)
							{
								canChange = false;
								FlxG.save.data.fullscreen = !FlxG.save.data.fullscreen;
		
								new FlxTimer().start(1, function(_)
									{
										canChange = true;
									});
							}
					}
			}
		
		FlxG.fullscreen = FlxG.save.data.fullscreen;

		#if hl
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		#else
		var pressedEnter:Bool = controls.ACCEPT;
		#end

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (pressedEnter && !transitioning && skippedIntro)
		{

			if (FlxG.save.data.flashing)
			{
				FlxG.camera.flash(FlxColor.WHITE, 1);
				titleText.animation.play('press');
			}
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			MainMenuState.firstStart = true;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.mouse.visible = false;
				FlxG.switchState(new AdviceState());
				//FlxG.switchState(new MainMenuState());
			});
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			case 3:
				addMoreText('present');
			case 4:
				deleteCoolText();
			case 5:
				createCoolText(['Universal Engine', 'by']);
			case 7:
				addMoreText('TheGalo X');
			case 8:
				deleteCoolText();
			case 9:
				createCoolText(['Credits to']);
			case 11:
				addMoreText('Kade Engine');
				addMoreText('Psych Engine');
			case 12:
				deleteCoolText();
			case 13:
				addMoreText('Friday');
			case 14:
				addMoreText('Night');
			case 15:
				addMoreText('Funkin');

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
			canChange = true;
		}
	}
}
