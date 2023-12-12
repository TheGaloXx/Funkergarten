package states;

import input.Controls.ActionType;
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

class CreditsState extends funkin.MusicBeatState
{
	var credits:Array<CreditMetadata> = [];

	var curSelected:Int = 0;
	private var showing:Bool = false;

	private var grpCredits:Array<objects.DialogueBox.IconBox> = [];

	private var iconArray:Array<objects.HealthIcon> = [];

	private var saul:FlxSprite;
    var descText:FlxText;
	var socialBlock:FlxSprite; // this reminds me of my history classes
	var socialText:FlxText;
	private var camFollow:flixel.FlxObject;

	private var daY:Float;

	override function create()
	{
		camFollow = new flixel.FlxObject(0, 0, 1, 1);
		camFollow.screenCenter(X);
		camFollow.active = false;

		CoolUtil.title('Credits Menu');

		credits = [];

		//		   name						roles									color		          social media						
		addCredit('JesseArtistXD', 			[DIRECTOR, ARTIST],						0xfb2944,			'https://twitter.com/ARandomHecker');
		addCredit('RealG', 					[DIRECTOR, COMPOSER, CHARTER],			0x2d6077,			'https://cdn.discordapp.com/attachments/1039977200205692959/1180102269807628379/F-n5KReaAAARWld.jpg?ex=657c32e2&is=6569bde2&hm=64d271fd21c98989c97338fbacf0a31e3588f3308646528640b67e9bf47f83fe&');
		addCredit('Anyone', 				[CHARTER],								0x60dc2c,			'https://www.youtube.com/@Anyoneplays826');
		addCredit('Croop x', 				[CHARTER],								0xfb1616,			'');
		addCredit('Enzo', 					[COMPOSER, SUPPORT],					0xd679bf,			'https://www.youtube.com/@Enzoolegal');
		addCredit('12kNoodles', 			[ARTIST],								0x281c34,			'https://www.youtube.com/@noddlet');
		addCredit('KrakenPower', 			[COMPOSER],								0xffc400,			'https://www.youtube.com/channel/UCMtErOjjmrxFyA5dH1GiRhQ');
		addCredit('Nosk', 					[ARTIST],								0x981e34,			'https://twitter.com/nosk_artist');
		addCredit('SaltyDaBlock', 			[COMPOSER, ARTIST, CHROMATICS],			0xff348c,			'https://www.youtube.com/@ItzTamago');
		addCredit('Sanco', 					[CODER],								0xffffff,			'https://github.com/SanicBTW');
		addCredit('TheGalo X', 				[CODER, ARTIST, ANIMATOR, COMPOSER], 	0xffee00,			'https://www.youtube.com/@TheGaloX');

		var time = Date.now().getHours();

		var bg = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('menu/credits_assets', 'preload');
		bg.animation.addByPrefix('idle', 'paper', 0, false);
		bg.animation.play('idle');
		bg.updateHitbox();
		bg.active = false;
		bg.scrollFactor.set();

		if (time > 19 || time < 8)
			bg.alpha = 0.7;
		add(bg);

		for (i in 0...credits.length)
		{
			var sprite = new objects.DialogueBox.IconBox(credits[i].devName, credits[i].devName, credits[i].color, false);
			sprite.y += 50 + ((sprite.height + 70) * i);
			grpCredits.push(sprite);
			add(sprite);
		}

        descText = new FlxText(5,0, 0, "", 26);
		descText.scrollFactor.set();
		descText.setFormat(null, 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2;
		descText.active = false;
        add(descText);
        descText.y = FlxG.height - descText.height;

		changeSelection();

		saul = new FlxSprite();
		saul.frames = Paths.getSparrowAtlas('menu/credits_assets', 'preload');
		saul.animation.addByPrefix('idle', 'saul hombre bueno', 0, false);
		saul.animation.play('idle');
		saul.setGraphicSize(FlxG.width, FlxG.height);
		saul.updateHitbox();
		saul.screenCenter();
		saul.loadGraphic(Paths.image('menu/croop', 'preload'));
		saul.alpha = 0;
		saul.active = false;
		saul.scrollFactor.set();
		add(saul);

		socialBlock = new FlxSprite(0,0).makeGraphic(1, 1, FlxColor.BLACK);
		socialBlock.scale.set(FlxG.width * 0.6 + 50, FlxG.height * 0.7);
		socialBlock.updateHitbox();
		socialBlock.alpha = 0;
		socialBlock.screenCenter();
		socialBlock.scrollFactor.set();
		add(socialBlock);

		socialText = new FlxText(0,0,0, "No social media!", 80);
		socialText.alpha = 0;
		socialText.scrollFactor.set();
		socialText.setFormat(null, 80, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		socialText.borderSize = 8;
		socialText.screenCenter();
		add(socialText);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			funkin.Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		if (showing && saul.alpha < 0.4) saul.alpha += elapsed * 0.15;
		else if (!showing) saul.alpha = 0;

		for (i in 0...grpCredits.length)
			if (i != curSelected)
				grpCredits[i].x = flixel.math.FlxMath.lerp(objects.DialogueBox.IconBox.daX, grpCredits[i].x, 0.5 * (elapsed * 30));

		camFollow.y = flixel.math.FlxMath.lerp(camFollow.y, daY, 0.5 * (elapsed * 30));
		FlxG.camera.focusOn(camFollow.getPosition());

		input();
	}

	function addCredit(devName:String, roles:Array<Roles>, color:FlxColor = 0xffffff, link:String = ''):Void
	{
		var rolesString:String = '';

		if (roles.length > 0)
		{
			for (rol in roles)
			{
				var daRole = Language.get('CreditsState', '${Std.string(rol).toLowerCase()}_role');

				if (roles.indexOf(rol) == 0)
					daRole = CoolUtil.firstLetterUpperCase(daRole);
				
				if (roles[0] == rol && roles.length == 1)
				{
					rolesString += '$daRole.';
				}
				else if (roles.indexOf(rol) == roles.length - 1)
				{
					rolesString += '& $daRole.';
				}
				else
				{
					rolesString += '$daRole, ';
				}
			}
		}
		roles = null;

		credits.push(new CreditMetadata(devName, rolesString, color, link));
	}

	function changeSelection(change:Int = 0)
	{
		CoolUtil.sound('scrollMenu', 'preload', 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = credits.length - 1;
		if (curSelected >= credits.length)
			curSelected = 0;

		descText.text = credits[curSelected].roles;

		for (i in 0...grpCredits.length)
		{
			var spr = grpCredits[i];
			if (i == curSelected)
			{
				daY = spr.box.y + spr.box.height / 2;
				spr.iconBop();
				spr.box.color = flixel.util.FlxColor.YELLOW;
				spr.x = 120;
			}
			else
				spr.box.color = spr.daColor;
		}

		if (credits[curSelected].devName == 'RealG' || credits[curSelected].devName == 'Croop x')
		{
			showing = true;

			if (credits[curSelected].devName == 'RealG')
			{
				trace('CHANGING TO SAUL!!');
				saul.frames = Paths.getSparrowAtlas('menu/credits_assets', 'preload');
				saul.animation.addByPrefix('idle', 'saul hombre bueno', 0, false);
				saul.animation.play('idle');
			}
			else
			{
				trace('CHANGING TO CROOP!!');
				saul.loadGraphic(Paths.image('menu/croop', 'preload'));
			}

			saul.setGraphicSize(FlxG.width, FlxG.height);
			saul.updateHitbox();
			saul.screenCenter();
			saul.scrollFactor.set();
		}
		else
			showing = false;
	}

	function noSocialMedia():Void
		{
			FlxTween.cancelTweensOf(socialBlock);
			FlxTween.cancelTweensOf(socialText);
			
			socialBlock.alpha = 0.65;
			socialBlock.screenCenter();
			socialBlock.velocity.set();
			socialBlock.acceleration.set();
			socialBlock.acceleration.y = FlxG.random.int(400, 500);
			socialBlock.angle = 0;

			socialText.alpha = 1;
			socialText.screenCenter();
			socialText.velocity.set();
			socialText.acceleration.set();
			socialText.angle = 0;

			FlxTween.tween(socialBlock, {alpha: 0, angle: FlxG.random.int(5, -5)}, 1.5, {startDelay: 0.1, ease: FlxEase.expoOut});
			FlxTween.tween(socialText, {alpha: 0, angle: FlxG.random.int(5, -5), y: 375}, 1.5, {startDelay: 0.1, ease: FlxEase.expoOut});
		}

	private function input()
	{
		if (FlxG.mouse.wheel > 0)
			changeSelection(-1);
		else if (FlxG.mouse.wheel < 0)
			changeSelection(1);

		if (FlxG.mouse.justPressed)
		{
			trace(credits[curSelected].devName + " selected");

			if (credits[curSelected].link != '')
				fancyOpenURL(credits[curSelected].link);
			else
				noSocialMedia();
		}
	}

	override function onActionPressed(action:ActionType)
	{
		switch(action)
		{
			case UI_UP:
				changeSelection(-1);
			case UI_DOWN:
				changeSelection(1);

			case BACK:
				CoolUtil.sound('cancelMenu', 'preload', 0.5);
				funkin.MusicBeatState.switchState(new MainMenuState());

			case CONFIRM:
				trace(credits[curSelected].devName + " selected");

				if (credits[curSelected].link != '')
					fancyOpenURL(credits[curSelected].link);
				else
					noSocialMedia();


			default:
				return;
		}
	}

	override function beatHit() 
	{
		super.beatHit();

		if (curBeat % 2 == 0 && ((curBeat >= 64 && curBeat <= 124) || (curBeat >= 192 && curBeat <= 252)))
			for (spr in grpCredits) spr.iconBop();
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

enum Roles
{
	DIRECTOR;
	ARTIST;
	COMPOSER;
	CHARTER;
	ANIMATOR;
	CHROMATICS;
	SUPPORT;
	CODER;
}