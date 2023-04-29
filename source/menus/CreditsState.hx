package menus;

import flixel.addons.ui.FlxUI.VarValue;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

//copypaste of freeplay XDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD

class CreditsState extends MusicBeatState
{
	var credits:Array<CreditMetadata> = [];

	var curSelected:Int = 0;

	private var grpCredits:FlxTypedGroup<Alphabet>;

	private var iconArray:Array<HealthIcon> = [];

	private var memes:Array<FlxSprite> = [];
    var descText:FlxText;
	var blackScreen:FlxSprite;
	var enzoTxt:FlxText;

	private var isEnzoScreen:Bool = false;

	override function create()
	{
		CoolUtil.title('Credits Menu');
		CoolUtil.presence(null, 'Credits menu', false, 0, null);

		credits = [];

		//		   name						 role										color				  social media						
		addCredit('JesseArtistXD', 			'Director & artist.',						0xfb2944,			'https://twitter.com/ARandomHecker'							);
		addCredit('RealG', 					'Director, composer & charter.',			0x2d6077,			''															);
		addCredit('AndyDavinci', 			'Animator & chromatics maker.',				0x5fc7f0,			'https://youtube.com/channel/UCz4VKCEJwkXoHjJ8h83HNbA'		);
		addCredit('Anyone', 				'Charter.',									0x60dc2c,			''															);
		addCredit('Croop x', 				'Charter.',									0xfb1616,			''															);
		addCredit('Enzo', 					'Composer.',								0xd679bf,			''															);
		addCredit('kNoodles', 				"(It's actually 12kNoodles) Artist.",		0x281c34,			''															);
		addCredit('KrakenPower', 			'Composer.',								0xffc400,			'https://www.youtube.com/channel/UCMtErOjjmrxFyA5dH1GiRhQ'	);
		addCredit('Mercury', 				'Composer, artist & chromatics maker.',		0xe9685a,			''															);
		addCredit('Nosk', 					'Artist.',									0x981e34,			''															);
		addCredit('OneMemeyGamer', 			'Logo maker.',								0x615657,			''															);
		addCredit('TheGalo X', 				'Coder, artist & animator.', 				0xffee00,			'https://www.youtube.com/c/TheGaloX'						);
		addCredit('Sanco', 					'Coder.', 									0xffffff,			''															);

		var time = Date.now().getHours();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/paper', 'preload'));
		bg.active = false;
		if (time > 19 || time < 8)
			bg.alpha = 0.7;
		add(bg);

		grpCredits = new FlxTypedGroup<Alphabet>();
		add(grpCredits);

		for (i in 0...credits.length)
		{
			var creditText:Alphabet = new Alphabet(0, (70 * i) + 30, credits[i].devName, true, false, true);
            creditText.isCenter = true;
			creditText.screenCenter(X);
			creditText.targetY = i;
			grpCredits.add(creditText);

			creditText.color = credits[i].color;

			var icon:HealthIcon;
			if (credits[i].devName != null)
				{
					icon = new HealthIcon('bf');
					icon.loadGraphic(Paths.image('icons/' + credits[i].devName));
					icon.animation.add('idle', [0], 0, false);
					icon.animation.play('idle');

					switch (credits[i].devName)	//hardcoding sucks
					{
						case 'KrakenPower': icon.flipX = true;	icon.setGraphicSize(Std.int(icon.width * 0.9));
						case 'TheGalo X': 	icon.setGraphicSize(Std.int(icon.width * 1.2));
					}
				}
			else
				icon = new HealthIcon('none');
			icon.sprTracker = creditText;

			iconArray.push(icon);
			add(icon);
		}

        descText = new FlxText(5,0, 0, "", 26);
		descText.scrollFactor.set();
		descText.setFormat(null, 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2;
		descText.active = false;
        add(descText);
        descText.y = FlxG.height - descText.height;

		changeSelection();

		var memeImg = ['saul hombre bueno', 'gustavo fring', 'galoxsanco', 'galoxsanco'];

		for (i in 0...memeImg.length)
		{
			var meme = new FlxSprite().loadGraphic(Paths.image('menu/${memeImg[i]}', 'preload'));
			meme.setGraphicSize(FlxG.width, FlxG.height);
			meme.updateHitbox();
			meme.screenCenter();
			meme.alpha = 0;
			meme.active = false;
			switch (i)
			{
				case 0: meme.ID = 1;
				case 1: meme.ID = 10;
				case 2: meme.ID = 11;
				case 3: meme.ID = 12;
			}
			add(meme);

			memes.push(meme);
		}

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.alpha = 0.75;
		blackScreen.visible = false;
		blackScreen.active = false;
		add(blackScreen);

		enzoTxt = new FlxText(0,0, FlxG.width, "Discord User: Enzoo#3889\n\n\n" + (KadeEngineData.settings.data.esp ? "Presiona ENTER para copiar al portapapeles o ESCAPE para retroceder." : "Press ENTER to copy to clipboard or ESCAPE to go back."), 64);
		enzoTxt.scrollFactor.set();
		enzoTxt.autoSize = false;
		enzoTxt.setFormat(null, 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		enzoTxt.borderSize = 10;
		enzoTxt.active = false;
		enzoTxt.screenCenter();
		enzoTxt.visible = false;
        add(enzoTxt);

		super.create();
	}

    var description:String = "";

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (meme in memes)
		{
			if (curSelected == meme.ID && meme.alpha < 0.4)
				meme.alpha += FlxG.elapsed * 0.15;
			else if (curSelected != meme.ID)
				meme.alpha = 0;
		}

		if (FlxG.sound.music.volume < (0.7 * KadeEngineData.settings.data.musicVolume))
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		input();
	}

	function addCredit(devName:String, roles:String, color:FlxColor = 0xffffff, link:String = ''):Void
		{
			credits.push(new CreditMetadata(devName, roles, color, link));
		}

	function changeSelection(change:Int = 0)
	{
		// NGio.logEvent('Fresh');
		CoolUtil.sound('scrollMenu', 'preload', 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = credits.length - 1;
		if (curSelected >= credits.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (item in grpCredits.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}

		descText.text = credits[curSelected].roles;
	}

	function noSocialMedia():Void
		{
			var dumb:FlxSprite = new FlxSprite(0,0).makeGraphic(Std.int(FlxG.width * 0.6 + 50), Std.int(FlxG.height * 0.7), FlxColor.BLACK);
			dumb.alpha = 0.5;
			dumb.screenCenter();
			dumb.acceleration.y = FlxG.random.int(400, 500);
			add(dumb);

			var text:FlxText = new FlxText(0,0,0, "No social media!", 80);
			text.scrollFactor.set();
			text.setFormat(null, 80, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.borderSize = 8;
			text.screenCenter();
			add(text);

			FlxTween.tween(dumb, {alpha: 0, angle: FlxG.random.int(5, -5)}, 1.5, {startDelay: 0.1, ease: FlxEase.expoOut});
			FlxTween.tween(text, {alpha: 0, angle: FlxG.random.int(5, -5), y: 375}, 1.5, {startDelay: 0.1, ease: FlxEase.expoOut, onComplete: function(_)
			{
				dumb.destroy();
				text.destroy();
			}});
		}

	private function doEnzo()
	{
		if (isEnzoScreen) return;
		isEnzoScreen = true;

		blackScreen.visible = true;
		enzoTxt.visible = true;
	}

	private function removeEnzo(copy:Bool)
	{
		if (!isEnzoScreen)	return;

		if (copy)
			openfl.desktop.Clipboard.generalClipboard.setData(TEXT_FORMAT, "Enzoo#3889");

		isEnzoScreen = false;
		blackScreen.visible = false;
		enzoTxt.visible = false;
	}

	private function input()
	{
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (!isEnzoScreen)
		{
			if (FlxG.mouse.wheel > 0 || FlxG.keys.justPressed.UP)
				changeSelection(-1);
			else if (FlxG.mouse.wheel < 0 || FlxG.keys.justPressed.DOWN)
				changeSelection(1);
	
			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
					changeSelection(-1);
				if (gamepad.justPressed.DPAD_DOWN)
					changeSelection(1);
			}
		}

		if (controls.BACK && !isEnzoScreen)
			MusicBeatState.switchState(new MainMenuState());
		else if (controls.BACK && isEnzoScreen)
			removeEnzo(false);

		if (controls.ACCEPT || FlxG.mouse.justPressed)
		{	
			trace(credits[curSelected].devName + " selected");
			
			if (!isEnzoScreen)
			{
				if (credits[curSelected].link != '')
					fancyOpenURL(credits[curSelected].link);
				else if (credits[curSelected].devName == 'Enzo')
					doEnzo();
				else
					noSocialMedia();
			}
			else
				removeEnzo(true);
		}
	}
}

class CreditMetadata
{
	public var devName:String = "";
	public var roles:String = "";
	public var color:FlxColor = 0xffffff;
	public var link:String = '';

	public function new(devName:String, roles:String, color:FlxColor = 0xffffff, link:String = '')
	{
		this.devName = devName;
		this.roles = roles;
		this.color = color;
		this.link = link;
	}
}
