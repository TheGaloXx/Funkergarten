package menus;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import lime.app.Application;
import flixel.util.FlxColor;

using StringTools;

//copypaste of freeplay XDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD

class CreditsState extends MusicBeatState
{
	var credits:Array<CreditMetadata> = [];

	var curSelected:Int = 0;

	private var grpCredits:FlxTypedGroup<Alphabet>;

	private var iconArray:Array<HealthIcon> = [];

    var descText:FlxText;
	var saul:FlxSprite;
	var gus:FlxSprite;

	override function create()
	{
		Application.current.window.title = (Main.appTitle + ' - Credits');

		credits = [];

		//		   name						 role										color				  social media
		addCredit('JesseArtistXD', 			'Director & artist.',						0xfb2944,			'https://twitter.com/ARandomHecker');
		addCredit('Agni', 					'Composer, artist & chromatics maker.',		0xe9685a,			'');
		addCredit('AndyDavinci', 			'Animator & chromatics maker.',				0x5fc7f0,			'https://youtube.com/channel/UCz4VKCEJwkXoHjJ8h83HNbA');
		addCredit('Anyone', 				'Charter.',									0x18b518,			'');
		addCredit('Croop x', 				'Charter.',									0xfb1616);
		addCredit('Enzo', 					'Composer.',								0xd679bf);
		addCredit('ERRon', 					'Charter & cool.',							0x7b787b);
		addCredit('KrakenPower', 			'Composer.',								0xffc400,			'https://www.youtube.com/channel/UCMtErOjjmrxFyA5dH1GiRhQ');
		addCredit('OneMemeyGamer', 			'Logo maker.',								0x615657);
		addCredit('RealG', 					'Composer & charter.',						0x2d6077);
		addCredit('TheGalo X', 				'Coder, artist & animator.', 				0xffee00,			'https://www.youtube.com/c/TheGaloX');
		//addCredit('ZenoYT', 				'Artist.', 									0xc71f50,			'twitter.com/bishzeno');

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/menuBGBlue'));
        bg.color = FlxColor.GRAY;
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
					icon = new HealthIcon('icons/' + credits[i].devName);
					icon.loadGraphic(Paths.image('icons/' + credits[i].devName));
					icon.animation.add('idle', [0], 0, false);
					icon.animation.play('idle');

					if (credits[i].devName == 'KrakenPower'){
						icon.flipX = true;
						icon.setGraphicSize(Std.int(icon.width * 0.9), Std.int(icon.height * 0.9));
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
        add(descText);
        descText.y = FlxG.height - descText.height;

		changeSelection();

		saul = new FlxSprite(0,0).loadGraphic(Paths.image('menu/saul hombre bueno'));
		saul.screenCenter();
		saul.alpha = 0;
		add(saul);

		gus = new FlxSprite(0,0).loadGraphic(Paths.image('menu/gustavo fring'));
		gus.screenCenter();
		gus.alpha = 0;
		add(gus);

		super.create();
	}

    var description:String = "";

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (curSelected != 8)	saul.alpha = 0;
		else
			{
				if (saul.alpha < 0.5)
					saul.alpha += FlxG.elapsed * 0.15;
			}

		if (curSelected != 7)	gus.alpha = 0;
		else
			{
				if (gus.alpha < 0.5)
					gus.alpha += FlxG.elapsed * 0.15;
			}

        descText.text = credits[curSelected].roles;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = controls.ACCEPT;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{	
			trace(credits[curSelected].devName + " selected");
			
			if (credits[curSelected].link != '')
				fancyOpenURL(credits[curSelected].link);
			else
				noSocialMedia();
		}
	}

	function addCredit(devName:String, roles:String, color:FlxColor = 0xffffff, link:String = ''):Void
		{
			credits.push(new CreditMetadata(devName, roles, color, link));
		}

	function changeSelection(change:Int = 0)
	{
		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = credits.length - 1;
		if (curSelected >= credits.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpCredits.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
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

			FlxTween.tween(dumb, {alpha: 0, angle: FlxG.random.int(5, -5)}, 1, {startDelay: 0.1, ease: FlxEase.expoOut});
			FlxTween.tween(text, {alpha: 0, angle: FlxG.random.int(10, -10), y: 375}, 1, {startDelay: 0.1, ease: FlxEase.expoOut, onComplete: function(_)
			{
				dumb.kill();
				text.kill();
			}});
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
