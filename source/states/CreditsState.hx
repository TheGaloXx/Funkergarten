package states;

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

	private var grpCredits:Array<objects.DialogueBox.IconBox> = [];

	private var iconArray:Array<objects.HealthIcon> = [];

	private var saul:FlxSprite;
    var descText:FlxText;
	var socialBlock:FlxSprite; // this reminds me of my history classes
	var socialText:FlxText;
	var blackScreen:FlxSprite;
	var enzoTxt:FlxText;
	private var camFollow:flixel.FlxObject;

	private var isEnzoScreen:Bool = false;
	private var daY:Float;

	override function create()
	{
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), data.KadeEngineData.settings.data.musicVolume);

		camFollow = new flixel.FlxObject(0, 0, 1, 1);
		camFollow.screenCenter(X);
		camFollow.active = false;

		CoolUtil.title('Credits Menu');
		CoolUtil.presence(null, 'Credits menu', false, 0, null);

		credits = [];

		//		   name						 role										color				  social media						
		addCredit('JesseArtistXD', 			'Director & artist.',						0xfb2944,			'https://twitter.com/ARandomHecker'							);
		addCredit('RealG', 					'Director, composer & charter.',			0x2d6077,			''															);
		addCredit('AndyDavinci', 			'Animator & chromatics maker.',				0x5fc7f0,			'https://youtube.com/channel/UCz4VKCEJwkXoHjJ8h83HNbA'		);
		addCredit('Anyone', 				'Charter.',									0x60dc2c,			''															);
		addCredit('Croop x', 				'Charter.',									0xfb1616,			''															);
		addCredit('Enzo', 					'Composer and emotional supporter.',		0xd679bf,			''															);
		addCredit('12kNoodles', 			"Artist.",									0x281c34,			''															);
		addCredit('KrakenPower', 			'Composer.',								0xffc400,			'https://www.youtube.com/channel/UCMtErOjjmrxFyA5dH1GiRhQ'	);
		addCredit('NoirExiko', 				'Composer, artist & chromatics maker.',		0xff348c,			''															);
		addCredit('Nosk', 					'Artist.',									0x981e34,			''															);
		addCredit('TheGalo X', 				'Coder, artist & animator.', 				0xffee00,			'https://www.youtube.com/c/TheGaloX'						);
		addCredit('Sanco', 					'Coder and owner of the custom sound tray.',0xffffff,			''															);

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
		saul.alpha = 0;
		saul.active = false;
		add(saul);

		socialBlock = new FlxSprite(0,0).makeGraphic(Std.int(FlxG.width * 0.6 + 50), Std.int(FlxG.height * 0.7), FlxColor.BLACK);
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

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.screenCenter();
		blackScreen.alpha = 0.75;
		blackScreen.visible = false;
		blackScreen.active = false;
		add(blackScreen);

		enzoTxt = new FlxText(0,0, FlxG.width, "Discord User: Enzoo#3889\n\n\n" + Language.get('CreditsState', 'enzo_text'), 64);
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

		if (FlxG.sound.music != null)
			funkin.Conductor.songPosition = FlxG.sound.music.time;

		if (curSelected == 1 && saul.alpha < 0.4) saul.alpha += elapsed * 0.15;
		else saul.alpha = 0;

		for (i in 0...grpCredits.length)
			if (i != curSelected)
				grpCredits[i].x = flixel.math.FlxMath.lerp(objects.DialogueBox.IconBox.daX, grpCredits[i].x, 0.5 * (elapsed * 30));

		camFollow.y = flixel.math.FlxMath.lerp(camFollow.y, daY, 0.5 * (elapsed * 30));
		FlxG.camera.focusOn(camFollow.getPosition());

		input();
	}

	function addCredit(devName:String, roles:String, color:FlxColor = 0xffffff, link:String = ''):Void
	{
		credits.push(new CreditMetadata(devName, roles, color, link));
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
			funkin.MusicBeatState.switchState(new MainMenuState());
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