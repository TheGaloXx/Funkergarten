package menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class MainMenuState extends MusicBeatState
{
	private var character:Character;
	private var logo:FlxSprite;
	private var selectedSomethin = false;
	private var notepad:FlxSprite;
	public static var difficulty:Int = 3;

	override function create()
	{
		CoolUtil.title('Main Menu');
		CoolUtil.presence(null, 'In the menus', false, 0, null);

		FlxG.mouse.visible = true;

		Conductor.changeBPM(130);

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), FlxG.save.data.musicVolume);

		persistentUpdate = persistentDraw = true;

		var red = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
		red.screenCenter();
		red.active = false;
		add(red);

		var bg:flixel.addons.display.FlxBackdrop = new flixel.addons.display.FlxBackdrop(Paths.image('menu/bgScroll'), X);
		bg.setGraphicSize(Std.int(bg.width * 0.8), Std.int(bg.height * 0.8));
		bg.updateHitbox();
		bg.scrollFactor.set();
		bg.screenCenter(Y);
		bg.velocity.x = -15;
		add(bg);

		var corners = new FlxSprite().loadGraphic(Paths.image('menu/corners', 'preload'));
		corners.active = false;
		corners.screenCenter();
		add(corners);

		var options:Array<String> = ['Story', 'Freeplay', 'Options'];

		for (i in 0...options.length)
		{
			var menuItem:Objects.MainMenuButton = new Objects.MainMenuButton(0, options[i]);
			menuItem.y += 50 + ((menuItem.height + 75) * i);
			menuItem.clickFunction = function()	doAction(options[i]);
			if (i == 2)
				menuItem.y += 100;
			add(menuItem);
		}

		notepad = new FlxSprite(150, -45);
		notepad.frames = Paths.getSparrowAtlas('menu/notepad', 'preload');
		notepad.animation.addByIndices('idleClosed', 'Notepad', [0], "", 0, false);
		notepad.animation.addByIndices('idleOpen', 'Notepad', [7], "", 0, false);
		notepad.animation.addByPrefix('open', 'Notepad', 24, false);
		notepad.animation.addByIndices('close', 'Notepad', [7, 6, 5, 4, 3, 2, 1, 0], "", 24, false);
		notepad.animation.play('idleClosed');
		notepad.setGraphicSize(Std.int(notepad.width * 0.6));
        notepad.updateHitbox();
		add(notepad);

		controls.setKeyboardScheme(Controls.KeyboardScheme.Duo(true), true);

		logo = new FlxSprite(0, 10).loadGraphic(Paths.image('menu/logo'));
		logo.scrollFactor.set();
		logo.setGraphicSize(Std.int(logo.width * 0.3), Std.int((logo.height * 0.3)));
		logo.updateHitbox();
		logo.screenCenter(X);
		add(logo);

		var allowedCharacters:Array<String> = ['nugget', 'monty', 'monster', 'protagonist', 'janitor', 'principal'];
		var charsList:Array<String> = FlxG.save.data.showCharacters;

		for (i in charsList)
		{
			if (!allowedCharacters.contains(i))
				charsList.remove(i);
		}

		character = new Character(0, 0, charsList[FlxG.random.int(0, charsList.length - 1)]);
		character.scrollFactor.set();
		trace(character.width + ' - ' + character.height);
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
		trace(character.width + ' - ' + character.height);

		var blackBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 32, FlxColor.BLACK);
		blackBar.scrollFactor.set();
		blackBar.alpha = 0.5;
		add(blackBar);

		flixel.tweens.FlxTween.tween(blackBar, {alpha: 0.25}, 2, {type: PINGPONG});

		eraseText = new flixel.text.FlxText(0, -4, 0, (FlxG.save.data.esp ? "Manten presionada la tecla R para borrar los datos.)" : "Hold the R key to erase saved data."), 44);
		eraseText.scrollFactor.set();
		eraseText.color = FlxColor.BLACK;
        eraseText.font = Paths.font('Crayawn-v58y.ttf');
		//eraseText.screenCenter(X);
		eraseText.x = FlxG.width;
		add(eraseText);

		flixel.tweens.FlxTween.tween(eraseText, {alpha: 0.5}, 2, {type: PINGPONG});

		var soundShit:SoundSetting = new SoundSetting();
		add(soundShit);

		super.create();
	}
	var eraseText:flixel.text.FlxText;

	var canHold:Bool = true;
	var time:Float = 0;

	override function update(elapsed:Float)
	{
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

		if (FlxG.mouse.overlaps(notepad))
		{
			if (notepad.animation.curAnim.name == 'idleClosed')
				notepad.animation.play('open');

			if (FlxG.mouse.justPressed)
				doAction('Credits');
		}
		else
		{
			if (notepad.animation.curAnim.name == 'idleOpen')
				notepad.animation.play('close');
		}

		logo.scale.set(flixel.math.FlxMath.lerp(0.3, logo.scale.x, 0.9), flixel.math.FlxMath.lerp(0.3, logo.scale.y, 0.9));

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
		if (eraseText.x < -600)
			eraseText.x = FlxG.width;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < (0.8 * FlxG.save.data.musicVolume))
			FlxG.sound.music.volume += (0.5 * FlxG.elapsed) * FlxG.save.data.musicVolume;

		if (FlxG.sound.music.volume > (0.8 * FlxG.save.data.musicVolume))
			FlxG.sound.music.volume = 0.8 * FlxG.save.data.musicVolume;

		super.update(elapsed);
	}

	override function beatHit()
		{
			if (curBeat % 2 == 0)
			{
				character.dance();
				logo.setGraphicSize(Std.int(logo.width * 1.2), Std.int(logo.height * 1.2));
			}

			super.beatHit();
		}
	
	function doAction(button:String):Void
	{
		if (selectedSomethin)
			return;
		selectedSomethin = true;

		CoolUtil.sound('confirmMenu', 'preload');

		new flixel.util.FlxTimer().start(0.5, function(_)
		{
			switch (button)
			{
				case 'Story':
					BackyardState.tellMonday = true;
					MusicBeatState.switchState(new BackyardState());
					trace("Story Menu Selected");

				case 'Freeplay':
					MusicBeatState.switchState(new FreeplayState());
					trace("Freeplay Menu Selected");

				case 'Options':
					MusicBeatState.switchState(new options.KindergartenOptions());
					trace("Options Menu Selected");
				case 'Credits':
					MusicBeatState.switchState(new menus.CreditsState());
					trace("Credits Menu Selected");
				default:
					selectedSomethin = false;
					trace("what");
			}
		});
	}
}
