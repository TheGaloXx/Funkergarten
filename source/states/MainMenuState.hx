package states;

import flixel.addons.display.FlxBackdrop;
import data.FCs;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.input.mouse.FlxMouseEvent;
import substates.DifficultySubstate;
import substates.OptionsAdviceSubstate;
import data.KadeEngineData;
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

	override function create()
	{
		Cache.clear();

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

		controls.setKeyboardScheme(data.Controls.KeyboardScheme.Duo(true), true);

		logo = new FlxSprite(0, 10).loadGraphic(Paths.image('menu/logo', 'preload'));
		logo.scrollFactor.set();
		logo.screenCenter(X);
		logo.y -= logo.height / 2 * daScale;
		logo.scale.set(daScale, daScale);
		add(logo);

		var allowedCharacters:Array<String> = ['nugget', 'monty', 'monster', 'protagonist', 'janitor', 'principal'];
		var charsList:Array<String> = data.KadeEngineData.other.data.showCharacters;

		for (i in charsList)
		{
			if (!allowedCharacters.contains(i))
				charsList.remove(i);
		}

		character = new objects.Character(0, 0, charsList[FlxG.random.int(0, charsList.length - 1)]);
		character.scrollFactor.set();
		if (character.curCharacter != 'principal')	character.setGraphicSize(300); else character.setGraphicSize(900);
		character.updateHitbox();
		switch(character.curCharacter)
		{
			case 'janitor': character.setPosition(-220, 60);
			case 'principal': character.setPosition(-510, 100);
			default: character.setPosition(10, FlxG.height - character.height - 100);
		}
		character.dance();
		add(character);
		red.color = FlxColor.fromString(character.curColor);
		corners.color = FlxColor.fromString(character.curColor);
		CoolUtil.glow(corners, 50, 50, corners.color);

		var blackBar:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackBar.scale.set(FlxG.width, 32);
		blackBar.updateHitbox();
		blackBar.scrollFactor.set();
		blackBar.alpha = 0.5;
		add(blackBar);

		flixel.tweens.FlxTween.tween(blackBar, {alpha: 0.25}, 2, {type: PINGPONG});

		eraseText = new flixel.text.FlxText(0, -4, 0, Language.get('MainMenuState', 'erase_text'), 44);
		eraseText.scrollFactor.set();
		eraseText.color = FlxColor.BLACK;
        eraseText.font = Paths.font('Crayawn-v58y.ttf');
		//eraseText.screenCenter(X);
		eraseText.x = FlxG.width;
		add(eraseText);

		flixel.tweens.FlxTween.tween(eraseText, {alpha: 0.5}, 2, {type: PINGPONG});

		var soundShit:objects.SoundSetting = new objects.SoundSetting();
		add(soundShit);

		var icon = new FlxSprite(5);
		icon.frames = Paths.getSparrowAtlas('menu/extras', 'preload');
		icon.animation.addByIndices('disabled', 'bf-icon', [0], '', 0, false);
		icon.animation.addByIndices('enabled', 'bf-icon', [1], '', 0, false);
		if (KadeEngineData.other.data.gotSkin)
			icon.animation.play('enabled');
		else
			icon.animation.play('disabled');
		icon.updateHitbox();
		icon.active = false;
		icon.y = soundShit.soundSprite.y - icon.height - 10;
		add(icon);

		FlxMouseEvent.add(icon, function onMouseDown(sprite)
		{
			if (KadeEngineData.other.data.gotSkin)
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

		if (KadeEngineData.other.data.sawAdvice)
			selectedSomethin = false;
		else
		{
			new FlxTimer().start(0.5, function(_)
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
	var eraseText:flixel.text.FlxText;

	var canHold:Bool = true;
	var time:Float = 0;

	private var code = ['N', 'U', 'G', 'G', 'E', 'T'];

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY && !data.KadeEngineData.other.data.polla && !selectedSomethin)
		{
			checkPolla();
		}

		#if debug
		if (FlxG.mouse.wheel != 0)
			FlxG.camera.zoom += (FlxG.mouse.wheel / 10);
		#end

		FlxG.watch.addQuick("Elapsed:", FlxG.elapsed);
		FlxG.watch.addQuick("Time holding R:", time);

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

		//erase data code
		if (FlxG.keys.pressed.R && canHold)
		{
			time += elapsed;
			if (time >= 1.25)
			{
				canHold = false;
				trace(time);
				openSubState(new substates.EraseData());
				canHold = true;
			}
		}
		else
			time = 0;

		if (FlxG.keys.justReleased.R){
			time = 0;
			canHold = true;
		}

		eraseText.x -= (200 * elapsed);

		if (eraseText.x < -eraseText.width)
			eraseText.x = FlxG.width;

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

		if (button == 'Freeplay' && cast(data.KadeEngineData.other.data.beatedSongs, Array<Dynamic>).length <= 0 && !data.KadeEngineData.other.data.polla)
		{
			CoolUtil.sound('cancelMenu', 'preload', 0.5);
			FlxG.cameras.shake(0.005, 0.25);

			return;
		}

		selectedSomethin = true;

		CoolUtil.sound('confirmMenu', 'preload');

		if (button != 'Story')
			bg.acceleration.x = -1000;

		new flixel.util.FlxTimer().start(0.5, function(_)
		{
			switch (button)
			{
				case 'Story':
					var dumbass = new DifficultySubstate();
					dumbass.closeCallback = function() selectedSomethin = false;
					openSubState(dumbass);
					trace("Story Menu Selected");

				case 'Freeplay':
					funkin.MusicBeatState.switchState(new FreeplayState());
					trace("Freeplay Menu Selected");

				case 'Options':
					funkin.MusicBeatState.switchState(new options.KindergartenOptions(null));
					trace("Options Menu Selected");
				case 'Credits':
					funkin.MusicBeatState.switchState(new states.CreditsState());
					trace("Credits Menu Selected");
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
			data.KadeEngineData.other.data.polla = true;
			selectedSomethin = true;

			var polla = new FlxSprite().loadGraphic(Paths.image('characters/nugget', 'shit'));
			polla.setGraphicSize(FlxG.width, FlxG.height);
			polla.updateHitbox();
			polla.screenCenter();
			polla.active = false;
			add(polla);

			FlxG.sound.music.stop();
			CoolUtil.sound('vine', 'shit');

			new FlxTimer().start(2, function(_)
			{
				secretSong('nugget-de-polla', 2);
			});
		}
	}
}
