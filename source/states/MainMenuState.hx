package states;

import options.OptionsMenu;
import flixel.tweens.FlxTween;
import objects.Character;
import flixel.addons.display.FlxBackdrop;
import data.FCs;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.input.mouse.FlxMouseEvent;
import substates.DifficultySubstate;
import substates.OptionsAdviceSubstate;
import data.GlobalData;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import substates.SelectSkinSubstate;

class MainMenuState extends funkin.MusicBeatState
{
	private var bg:FlxBackdrop;
	private var character:objects.Character;
	private var logo:FlxSprite;
	private var selectedSomethin = true;
	private var notepad:FlxSprite;
	private final daScale:Float = 0.5;
	public static var shown:String;

	override function create()
	{
		CoolUtil.title('Main Menu');
		CoolUtil.presence(null, Language.get('Discord_Presence', 'main_menu'), false, 0, null);

		var red = new FlxSprite().makeGraphic(1, 1);
		red.scale.set(FlxG.width, FlxG.height);
		red.updateHitbox();
		red.screenCenter();
		red.active = false;
		add(red);

		bg = new FlxBackdrop(Paths.image('menu/bgScroll', 'preload'), X);
		bg.scrollFactor.set();
		bg.screenCenter(Y);
		bg.velocity.x = -15;
		bg.x = FlxG.random.int(0, 6400);
		add(bg);

		var corners = new FlxSprite().loadGraphic(Paths.image('menu/corners', 'preload'));
		corners.active = false;
		add(corners);

		var options:Array<String> = ['Story', 'Freeplay', 'Options'];

		for (i in 0...options.length)
		{
			var menuItem:objects.Objects.MainMenuButton = new objects.Objects.MainMenuButton(0, options[i]);
			menuItem.y += 50 + ((menuItem.height + 75) * i);
			menuItem.clickFunction = function()	doAction(options[i]);
			add(menuItem);
		}

		notepad = new FlxSprite(150, -45);
		notepad.frames = Paths.getSparrowAtlas('menu/mainmenu_assets', 'preload');
		notepad.animation.addByIndices('idleClosed', 'Notepad', [0], "", 0, false);
		notepad.animation.addByIndices('idleOpen', 'Notepad', [7], "", 0, false);
		notepad.animation.addByPrefix('open', 'Notepad', 24, false);
		notepad.animation.addByIndices('close', 'Notepad', [7, 6, 5, 4, 3, 2, 1, 0], "", 24, false);
		notepad.animation.play('idleClosed');
		// notepad.setGraphicSize(Std.int(notepad.width * 0.6));
        notepad.updateHitbox();
		add(notepad);

		if (!GlobalData.other.seenCredits)
			FlxTween.color(notepad, 1, FlxColor.WHITE, 0xffff9393, {type: PINGPONG});

		logo = new FlxSprite(0, 10).loadGraphic(Paths.image('menu/logo', 'preload'));
		logo.scrollFactor.set();
		logo.screenCenter(X);
		logo.y -= logo.height / 2 * daScale;
		logo.scale.set(daScale, daScale);
		add(logo);

		var savedChars:Array<String> = GlobalData.other.menuCharacters;
		var charsList:Array<String> = savedChars.copy();

		charsList.remove('protagonist-pixel');

		for (i in charsList)
		{
			if (!GlobalData.allowedMenuCharacters.contains(i))
				charsList.remove(i);
		}

		if (charsList.length > 1)
			charsList.remove(shown);

		character = new objects.Character(0, 0, charsList[FlxG.random.int(0, charsList.length - 1)]);
		character.scrollFactor.set();
		setDumbCharacter(character);
		character.dance();
		add(character);
		red.color = FlxColor.fromString(character.curColor);
		corners.color = FlxColor.fromString(character.curColor);
		CoolUtil.glow(corners, 50, 50, corners.color);

		shown = character.curCharacter;

		var soundShit:objects.SoundSetting = new objects.SoundSetting();
		add(soundShit);

		var icon = new FlxSprite(5);
		icon.frames = Paths.getSparrowAtlas('menu/extras', 'preload');
		icon.animation.addByIndices('disabled', 'bf-icon', [0], '', 0, false);
		icon.animation.addByIndices('enabled', 'bf-icon', [1], '', 0, false);
		if (GlobalData.other.gotSkin)
			icon.animation.play('enabled');
		else
			icon.animation.play('disabled');
		icon.updateHitbox();
		icon.active = false;
		icon.y = soundShit.soundSprite.y - icon.height - 10;
		add(icon);

		FlxMouseEvent.add(icon, function onMouseDown(sprite)
		{
			if (GlobalData.other.gotSkin)
				openSubState(new SelectSkinSubstate());
			else
			{
				CoolUtil.sound('cancelMenu', 'preload', 0.5);
				FlxG.cameras.shake(0.005, 0.25);
			}
		}, null, null, null);

		if (FCs.fullFC())
		{
			var star = new FlxSprite();
			star.frames = Paths.getSparrowAtlas('menu/extras', 'preload');
			star.animation.addByIndices('idle', 'star', [0], '', 0, false);
			star.animation.play('idle');
			star.updateHitbox();
			star.active = false;
			star.y = icon.y - star.height - 10;
			add(star);
		}

		if (GlobalData.other.sawAdvice)
			selectedSomethin = false;
		else
		{
			FlxTimer.wait(0.5, () ->
			{
				var substate = new OptionsAdviceSubstate();
				substate.closeCallback = function()
				{
					selectedSomethin = false;
				}
				openSubState(substate);
			});
		}

		super.create();
	}

	private var code = ['N', 'U', 'G', 'G', 'E', 'T'];

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY && !GlobalData.other.didPolla && !selectedSomethin)
		{
			checkPolla();
		}

		#if debug
		if (FlxG.mouse.wheel != 0)
			FlxG.camera.zoom += (FlxG.mouse.wheel / 10);
		#end

		FlxG.watch.addQuick("Elapsed:", FlxG.elapsed);

		//	idleClosed	idleOpen open close

		if (notepad.animation.curAnim.name == 'open' && notepad.animation.curAnim.finished)
			notepad.animation.play('idleOpen', true);
		if (notepad.animation.curAnim.name == 'close' && notepad.animation.curAnim.finished)
			notepad.animation.play('idleClosed', true);

		if (CoolUtil.overlaps(notepad))
		{
			if (notepad.animation.curAnim.name == 'idleClosed')
				notepad.animation.play('open');

			if (FlxG.mouse.justPressed && !selectedSomethin)
				doAction('Credits');
		}
		else
		{
			if (notepad.animation.curAnim.name == 'idleOpen')
				notepad.animation.play('close');
		}

		if (FlxG.sound.music != null)
			funkin.Conductor.songPosition = FlxG.sound.music.time;

		var mult:Float = FlxMath.lerp(daScale, logo.scale.x, CoolUtil.boundTo(1 - (elapsed * 9)));
		logo.scale.set(mult, mult);

		super.update(elapsed);
	}

	override function beatHit()
	{
		if (curBeat % 2 == 0)
		{
			character.dance();
			logo.scale.set(daScale + 0.1, daScale + 0.1);
			// logo.updateHitbox();
		}

		super.beatHit();
	}
	
	function doAction(button:String):Void
	{
		if (selectedSomethin)
			return;

		selectedSomethin = true;

		CoolUtil.sound('confirmMenu', 'preload');

		if (button != 'Story')
			bg.acceleration.x = -1000;

		FlxTimer.wait(0.5, () ->
		{
			switch (button)
			{
				case 'Story':
					var dumbass = new DifficultySubstate();
					dumbass.closeCallback = function() selectedSomethin = false;
					openSubState(dumbass);

				case 'Freeplay':
					funkin.MusicBeatState.switchState(new FreeplayState());

				case 'Options':
					funkin.MusicBeatState.switchState(new OptionsMenu(MAIN));
				case 'Credits':
					funkin.MusicBeatState.switchState(new states.CreditsState());

					if (!GlobalData.other.seenCredits)
					{
						GlobalData.other.seenCredits = true;
						GlobalData.flush();
					}
				default:
					selectedSomethin = false;
					trace("what");
			}
		});
	}

	private function checkPolla():Void
	{
		var key:flixel.input.keyboard.FlxKey = FlxG.keys.firstJustPressed();
		if (code[0] == key)
		{
			CoolUtil.sound('scrollMenu', 'preload', 0.3);
			code.shift();
		}
		else if (code[0] != 'N')
		{
			CoolUtil.sound('cancelMenu', 'preload', 0.3);
			code = ['N', 'U', 'G', 'G', 'E', 'T'];
		}
		trace('[ Just pressed $key - code: $code ]');

		if (code.length <= 0)
		{
			GlobalData.other.didPolla = true;
			GlobalData.flush();
			selectedSomethin = true;

			var polla = new FlxSprite().loadGraphic(Paths.image('characters/nugget', 'shit'));
			polla.setGraphicSize(FlxG.width, FlxG.height);
			polla.updateHitbox();
			polla.screenCenter();
			polla.active = false;
			add(polla);

			FlxG.sound.music.stop();
			CoolUtil.sound('vine', 'shit');

			FlxTimer.wait(2, () ->
			{
				secretSong('nugget-de-polla', 2);
			});
		}
	}

	private function setDumbCharacter(character:Character):Void
	{
		final size:Array<Null<Float>> = switch (character.curCharacter)
		{
			case 'protagonist':
				[null, 66, 307];
			case 'nugget':
				[null, 2, 259];
			case 'janitor':
				[null, -42, 209];
			case 'monty':
				[null, 7, 338];
			case 'cindy':
				[null, -20, 320];
			case 'lily':
				[null, 5, 320];
			case 'monster':
				[null, 5, 150];
			case 'principal':
				[600, -295, 213];
			case 'polla':
				[null, 105, 440];
			case _:
				[0, 0, 0];
		}

		size[0] ??= 300;
		
		character.setGraphicSize(size[0]);
		character.updateHitbox();

		size[1] ??= 10;
		size[2] ??= 0;

		character.setPosition(size[1], size[2]);
	}
}
