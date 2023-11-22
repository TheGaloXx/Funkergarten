package debug;

import flixel.util.FlxCollision;
import lime.app.Application;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;

/**
	*DEBUG MODE
 */
using StringTools;

//THIS CODE IS FROM KADE ENGINE 1.8 BECAUSE I COULDNT DO IT MYSELF AND ITS VERY GOOD

class AnimationDebug extends funkin.MusicBeatState
{
	var ghost:objects.Character;
	var dad:objects.Character;
	var char:objects.Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;

	var UI_box:FlxUITabMenu;
	var UI_options:FlxUITabMenu;
	var offsetX:FlxUINumericStepper;
	var offsetY:FlxUINumericStepper;

	var characters:Array<String>;

	public function new(daAnim:String = 'bf')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0, 0); //gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		ghost = new objects.Character(0, 0, daAnim);
		ghost.screenCenter();
		ghost.debugMode = true;
		ghost.animation.play('idle');
		ghost.alpha = 0.5;
		add(ghost);
		ghost.flipX = false;
		//got this idea from Psych Engine

		dad = new objects.Character(0, 0, daAnim);
		dad.screenCenter();
		dad.debugMode = true;
		add(dad);

		char = dad;
		dad.flipX = false;

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		textAnim.scrollFactor.set();
		add(textAnim);

		genBoyOffsets();

		addHelpText();

		characters = Main.characters;
		characters.remove('polla');

		var tabs = [{name: "Offsets", label: 'Offset menu'},];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.scrollFactor.set();
		UI_box.resize(150, 200);
		UI_box.x = FlxG.width - UI_box.width - 20;
		UI_box.y = 20;

		add(UI_box);

		addOffsetUI();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	function addOffsetUI():Void
	{
		var player1DropDown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			remove(ghost);
			ghost = new objects.Character(0, 0, characters[Std.parseInt(character)]);
			ghost.screenCenter();
			ghost.debugMode = true;
			ghost.animation.play('idle');
			ghost.alpha = 0.5;
			add(ghost);
			ghost.flipX = false;
			//got this idea from Psych Engine

			remove(dad);
			dad = new objects.Character(0, 0, characters[Std.parseInt(character)]);
			dad.screenCenter();
			dad.debugMode = true;
			dad.flipX = false;
			add(dad);

			replace(char, dad);
			char = dad;

			dumbTexts.clear();
			genBoyOffsets(true, true);
			updateTexts();
		});

		player1DropDown.selectedLabel = char.curCharacter;

		var offsetX_label = new FlxText(10, 50, 'X Offset');

		var UI_offsetX:FlxUINumericStepper = new FlxUINumericStepper(10, offsetX_label.y + offsetX_label.height + 10, 1,
			char.animOffsets.get(animList[curAnim])[0], -500.0, 500.0, 0);
		UI_offsetX.value = char.animOffsets.get(animList[curAnim])[0];
		UI_offsetX.name = 'offset_x';
		offsetX = UI_offsetX;

		var offsetY_label = new FlxText(10, UI_offsetX.y + UI_offsetX.height + 10, 'Y Offset');

		var UI_offsetY:FlxUINumericStepper = new FlxUINumericStepper(10, offsetY_label.y + offsetY_label.height + 10, 1,
			char.animOffsets.get(animList[curAnim])[0], -500.0, 500.0, 0);
		UI_offsetY.value = char.animOffsets.get(animList[curAnim])[1];
		UI_offsetY.name = 'offset_y';
		offsetY = UI_offsetY;

		var tab_group_offsets = new FlxUI(null, UI_box);
		tab_group_offsets.name = "Offsets";

		tab_group_offsets.add(offsetX_label);
		tab_group_offsets.add(offsetY_label);
		tab_group_offsets.add(UI_offsetX);
		tab_group_offsets.add(UI_offsetY);
		tab_group_offsets.add(player1DropDown);

		UI_box.addGroup(tab_group_offsets);
	}

	function genBoyOffsets(pushList:Bool = true, ?cleanArray:Bool = false):Void
	{
		if (cleanArray)
			animList.splice(0, animList.length);

		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			text.color = FlxColor.WHITE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		offsetX.value = char.animOffsets.get(animList[curAnim])[0];
		offsetY.value = char.animOffsets.get(animList[curAnim])[1];

		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	var helpText:FlxText;

	function addHelpText():Void
		{
			helpText = new FlxText(940, 20, 0, "Help:\nQ/E : Zoom in and out\nF : Flip\nI/J/K/L : Move Camera\nW/S : Change Animation\nArrows : Set Animation Offset\nShift-Arrows : Set Animation Offset x10\nSpace : Replay Animation\nEnter/ESC : Exit\nPress F1 to hide/show this!\n", 15);
			helpText.scrollFactor.set();
			helpText.y = FlxG.height - helpText.height - 20;
			helpText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			helpText.color = FlxColor.WHITE;
	
			add(helpText);
		}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var offset:FlxUINumericStepper = cast sender;
			var offsetName = offset.name;
			switch (offsetName)
			{
				case 'offset_x':
					char.animOffsets.get(animList[curAnim])[0] = offset.value;
					updateTexts();
					genBoyOffsets(false);
					char.playAnim(animList[curAnim]);
				case 'offset_y':
					char.animOffsets.get(animList[curAnim])[1] = offset.value;
					updateTexts();
					genBoyOffsets(false);
					char.playAnim(animList[curAnim]);
			}
		}
	}

	override function update(elapsed:Float)
	{
		textAnim.text = char.animation.curAnim.name;

		if (FlxG.keys.justPressed.ESCAPE)
			funkin.MusicBeatState.switchState(new states.PlayState());

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.justPressed.F)
		{
			ghost.flipX = !ghost.flipX;
			char.flipX = !char.flipX;
		}

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
			camFollow.velocity.set();

		if (FlxG.keys.justPressed.W)
			curAnim -= 1;

		if (FlxG.keys.justPressed.S)
			curAnim += 1;

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim]);

			updateTexts();
			genBoyOffsets(false);
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

			updateTexts();
			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
		}

		if (FlxG.keys.justPressed.F1)
			data.KadeEngineData.showHelp = !data.KadeEngineData.showHelp;

		helpText.text = (data.KadeEngineData.showHelp ? "Help:\nQ/E : Zoom in and out\nF : Flip\nI/J/K/L : Move Camera\nW/S : Change Animation\nArrows : Set Animation Offset\nShift-Arrows : Set Animation Offset x10\nSpace : Replay Animation\nEnter/ESC : Exit\nPress F1 to hide/show this!\n" : "F1 - help");

		super.update(elapsed);
	}
}