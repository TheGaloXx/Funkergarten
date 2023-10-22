package objects;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import objects.Objects.DialogueIcon;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite; //box
	var icon:DialogueIcon; //character icon
	var swagDialogue:FlxTypeText; //dialogue text

	var curCharacter:String = ''; //uhh character
	var dialogueList:Array<String> = []; //dialogue
	var angry:String = '';
	var speed:Float;
	var size:Int;
	var yellow:String = '';

	public var finishThing:Void->Void; //finishing function

	var dialogueAppeared:Bool = false;
	var dialogueStarted:Bool = false;
	var isEnding:Bool = false;

	public var canSkip:Bool = true;

	public function new(dialogueList:Array<String>, hasMusic:Bool = true) //angry:bool  	for the bigger text
	{
		super();

		trace("Creating objects.DialogueBox");

		this.dialogueList = dialogueList;

		if (hasMusic)
		{
			FlxG.sound.playMusic(Paths.music('world theme', 'preload'), 0); //music that fades in
			FlxG.sound.music.fadeIn(1, 0, 0.7 * data.KadeEngineData.settings.data.musicVolume);
		}

		box = new FlxSprite(0, 920).loadGraphic(Paths.image('gameplay/dialogue'), 'shared'); //box
		box.scrollFactor.set();
		box.screenCenter(X);
		box.color = FlxColor.fromString(states.PlayState.dad.curColor);
		add(box);

		icon = new DialogueIcon(80, 960, states.PlayState.dad.curCharacter); //character icon
		box.color = icon.daColor;
		add(icon);

		swagDialogue = new FlxTypeText(225, 560, Std.int(FlxG.width * 0.8), "", 64); //text
		swagDialogue.font = Paths.font('Crayawn-v58y.ttf');
		swagDialogue.color = FlxColor.BLACK;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('text', 'shared'), 0.6)];
		add(swagDialogue);

		//things movement
		FlxTween.tween(icon, {y: 560}, 0.5, {ease: FlxEase.sineInOut});
		FlxTween.tween(box, {y: 520}, 0.5, {ease: FlxEase.sineOut, onComplete: function(_)	dialogueAppeared = true	});
		trace("Finished creating objects.DialogueBox");
	}

	override function update(elapsed:Float)
	{
		if (dialogueAppeared && !dialogueStarted) //dialogue appeared
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.anyJustPressed([ENTER, SPACE, BACKSPACE, ESCAPE]) && dialogueStarted && canSkip)
		{		
			CoolUtil.sound('cancelMenu', 'preload', 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
				endDialogue();
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	function startDialogue():Void
	{
		cleanDialog();

		box.color = icon.daColor;

		if (icon.char != curCharacter)
		{
			remove(icon);
			icon = new DialogueIcon(80, 560, curCharacter); //character icon
			add(icon);
		}
		
		if (icon != null)
			icon.animation.play('talking');

		//if angry, faster and bigger text, if not angry, normal speed and size text
		if (angry == 'true')
			{speed = 0.03; size = 128; FlxG.cameras.shake(0.0075, 0.5);}
		else if (angry != 'true') 
			{speed = 0.04; size = 64;}

		if (yellow == 'true')
			swagDialogue.color = FlxColor.YELLOW;
		else
			swagDialogue.color = FlxColor.BLACK;

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.size = size;
		swagDialogue.start(speed, true, false, [], function() if (icon != null) icon.animation.play('idle'));
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");

		curCharacter = splitName[0];
		dialogueList[0] = splitName[1];
		angry = splitName[2];
		yellow = splitName[3];

		if (angry != 'true' || angry == null || angry == '')
			angry = 'false';
		if (yellow != 'true' || yellow == null || yellow == '')
			yellow = 'false';

		trace("\n\nCharacter: " + splitName[0] + '\nDialogue: "' + splitName[1] + '"\nAngry: ' + splitName[2] + "\nYellow: " + splitName[3] + "\n\n" + ((dialogueList[1] == null && dialogueList[0] != null) ? "No more dialogues.\n\n" : "Next dialogue:\n"));

		box.color = icon.daColor;

		if (icon.char != curCharacter)
		{
			remove(icon);
			icon = new DialogueIcon(80, 560, curCharacter); //character icon
			add(icon);
		}
	}

	function endDialogue():Void
	{
		if (!isEnding)
			{
				isEnding = true;

				swagDialogue.kill();
				swagDialogue.destroy();
				FlxTween.tween(icon, {y: 960}, 0.5, {ease: FlxEase.sineOut});
				FlxTween.tween(box, {y: 920}, 0.5, {ease: FlxEase.sineOut});

				if (FlxG.sound.music != null)
					FlxG.sound.music.fadeOut(0.5, 0, function(_) //dont ask
					{
						finishThing();

						box.kill();
						box.destroy();
						icon.kill();
						icon.destroy();
						kill();
						destroy();
					});
			}
	}
}

class NuggetDialogue extends FlxSpriteGroup
{
	var box:FlxSprite; //box
	var icon:DialogueIcon; //character icon
	var swagDialogue:FlxTypeText; //dialogue text

	var dialogueList:Array<String> = []; //dialogue
	var angry:String = '';
	var speed:Float;
	var size:Int;
	var yellow:String = '';

	public var finishThing:Void->Void; //finishing function

	var dialogueAppeared:Bool = false;
	var dialogueStarted:Bool = false;
	var isEnding:Bool = false;

	public var canSkip:Bool = true;

	public function new(dialogueList:Array<String>) //angry:bool  	for the bigger text
	{
		super();

		trace("Creating DialogueBox");

		this.dialogueList = dialogueList;

		box = new FlxSprite(0, 920).loadGraphic(Paths.image('gameplay/dialogue'), 'shared'); //box
		box.scrollFactor.set();
		box.screenCenter(X);
		box.color = 0xe58966;
		add(box);
		
		add(icon = new DialogueIcon(80, 960, 'nugget'));

		swagDialogue = new FlxTypeText(225, 560, Std.int(FlxG.width * 0.8), "", 64); //text
		swagDialogue.font = Paths.font('Crayawn-v58y.ttf');
		swagDialogue.color = FlxColor.BLACK;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('text', 'shared'), 0.6)];
		add(swagDialogue);

		//things movement
		FlxTween.tween(icon, {y: 560}, 0.5, {ease: FlxEase.sineInOut});
		FlxTween.tween(box, {y: 520}, 0.5, {ease: FlxEase.sineOut, onComplete: function(_)	dialogueAppeared = true	});
		trace("Finished creating objects.DialogueBox");
	}

	override function update(elapsed:Float)
	{
		if (dialogueAppeared && !dialogueStarted) //dialogue appeared
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.anyJustPressed([ENTER, SPACE, BACKSPACE, ESCAPE]) && dialogueStarted && canSkip)
		{		
			CoolUtil.sound('cancelMenu', 'preload', 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
				endDialogue();
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	function startDialogue():Void
	{
		cleanDialog();
		
		if (icon != null)
			icon.animation.play('talking');

		//if angry, faster and bigger text, if not angry, normal speed and size text
		if (angry == 'true')
			{speed = 0.03; size = 128; FlxG.cameras.shake(0.0075, 0.5);}
		else if (angry != 'true') 
			{speed = 0.04; size = 64;}

		if (yellow == 'true')
			swagDialogue.color = FlxColor.YELLOW;
		else
			swagDialogue.color = FlxColor.BLACK;

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.size = size;
		swagDialogue.start(speed, true, false, [], function() if (icon != null) icon.animation.play('idle'));
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");

		dialogueList[0] = splitName[0];
		angry = splitName[1];
		yellow = splitName[2];

		if (angry != 'true' || angry == null || angry == '')
			angry = 'false';
		if (yellow != 'true' || yellow == null || yellow == '')
			yellow = 'false';

		trace("\n\nDialogue: " + splitName[0] + '"\nAngry: ' + splitName[1] + "\nYellow: " + splitName[2] + "\n\n" + ((dialogueList[1] == null && dialogueList[0] != null) ? "No more dialogues.\n\n" : "Next dialogue:\n"));
	}

	function endDialogue():Void
	{
		if (!isEnding)
			{
				isEnding = true;

				swagDialogue.kill();
				swagDialogue.destroy();
				FlxTween.tween(icon, {y: 960}, 0.5, {ease: FlxEase.sineOut});
				FlxTween.tween(box, {y: 920}, 0.5, {ease: FlxEase.sineOut, onComplete: function(_)
				{
					finishThing();

					box.destroy();
					icon.destroy();
					destroy();
				}});
			}
	}
}

class IconBox extends FlxSpriteGroup
{
	public static var daX:Int = 60;
	public var box:FlxSprite;
	private var icon:objects.HealthIcon;
	private var isPolla:Bool;
	public var daColor:FlxColor;

	public function new(text:String, name:String, color:FlxColor, isFreeplay:Bool)
	{
		super();

		daColor = color;

		box = new FlxSprite().loadGraphic(Paths.image('gameplay/dialogue'), 'shared');
		box.scrollFactor.set();
		CoolUtil.size(box, 0.9);
		add(box);

        switch (name)
        {
            case 'nugget':
                daColor = 0xe58966;
            case 'protagonist':
                daColor = 0xc8c8c8;
            case 'janitor':
                daColor = 0x74b371;
            case 'monty':
                daColor = 0x85d3a2;
            case 'lady': //lol
                daColor = 0xc8b794;
            case 'buggs':
                daColor = 0x9d927b;
            case 'lily':
                daColor = 0x97d8e0;
            case 'cindy':
            	daColor = 0xddaddf;
            case 'applegate':
                daColor = 0xcd8ae2;
            case 'jerome':
                daColor = 0xe3bb39;
            default:
				if (isFreeplay) // me when 38593 json parsing errors:
                	daColor = FlxColor.fromString(new objects.Character(0,0,name).curColor);
        }

		box.color = daColor;

		icon = new objects.HealthIcon(name);
		icon.setPosition(20, 10);
		if (name == 'polla')
		{
			icon.loadGraphic(Paths.image('characters/nugget', 'shit'));
			icon.setGraphicSize(150);
			icon.updateHitbox();
			isPolla = true;
		}
		icon.animation.play(name);
		if (!isFreeplay)
		{
			icon.loadGraphic(Paths.image('icons/$name'));
			icon.animation.add('idle', [0], 0, false);
			icon.animation.play('idle');
			switch (name)	//hardcoding sucks
			{
				case 'TheGalo X': 	icon.setGraphicSize(Std.int(icon.width * 1.2));
			}
		}
		add(icon);

		var daText = new FlxTypeText(225, 25, Std.int(FlxG.width * 0.8), text, 100); //text
		daText.font = Paths.font('Crayawn-v58y.ttf');
		daText.color = FlxColor.BLACK;
		daText.start(0.05);
		daText.completeCallback = function() active = false;
		add(daText);
		daText.y = box.y + (box.height / 2) - (daText.height / 2) + 15;
	}

	public function iconBop():Void
	{
		FlxTween.cancelTweensOf(icon);
		if (!isPolla)
		{
			icon.scale.set(1.2, 1.2);
			FlxTween.tween(icon.scale, {x: 1, y: 1}, 0.5, {startDelay: 0.05, ease: flixel.tweens.FlxEase.sineOut});
		}
		else
		{
			icon.scale.set(0.673, 0.673);
			FlxTween.tween(icon.scale, {x: 0.473, y: 0.473}, 0.5, {startDelay: 0.05, ease: flixel.tweens.FlxEase.sineOut});
		}
	}
}