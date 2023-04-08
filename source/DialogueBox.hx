package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Objects.DialogueIcon;
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

	public function new(dialogueList:Array<String>, hasMusic:Bool = true) //angry:bool  	for the bigger text
	{
		super();

		trace("Creating DialogueBox");

		this.dialogueList = dialogueList;

		if (hasMusic)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'), 0); //music that fades in
			FlxG.sound.music.fadeIn(1, 0, 0.7 * KadeEngineData.settings.data.musicVolume);
		}

		box = new FlxSprite(0, 920).loadGraphic(Paths.image('gameplay/dialogue'), 'shared'); //box
		box.scrollFactor.set();
		box.screenCenter(X);
		box.color = FlxColor.fromString(PlayState.dad.curColor);
		add(box);
		
		icon = new DialogueIcon(80, 960, PlayState.dad.curCharacter); //character icon
		box.color = icon.daColor;
		add(icon);

		swagDialogue = new FlxTypeText(225, 560, Std.int(FlxG.width * 0.8), "", 64); //text
		swagDialogue.font = Paths.font('Crayawn-v58y.ttf');
		swagDialogue.color = FlxColor.BLACK;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('text', 'preload'), 0.6)];
		add(swagDialogue);

		//things movement
		FlxTween.tween(icon, {y: 560}, 0.5, {ease: FlxEase.sineInOut});
		FlxTween.tween(box, {y: 520}, 0.5, {ease: FlxEase.sineOut, onComplete: function(_)	dialogueAppeared = true	});
		trace("Finished creating DialogueBox");
	}

	override function update(elapsed:Float)
	{
		if (dialogueAppeared && !dialogueStarted) //dialogue appeared
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.anyJustPressed([ENTER, SPACE, BACKSPACE, ESCAPE]) && dialogueStarted)
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