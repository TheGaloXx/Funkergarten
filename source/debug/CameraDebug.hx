package debug;

import flixel.FlxCamera;
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

class CameraDebug extends funkin.MusicBeatState
{
	var dad:objects.Character;
	var char:objects.Character;
	var daAnim:String = 'spooky';
    var cameraPoint:FlxSprite;

	var UI_box:FlxUITabMenu;
	var UI_options:FlxUITabMenu;
	var camOffsets:FlxText;
	var charOffsets:FlxText;

	var characters:Array<String>;

    var strumLine:FlxSprite;
    var strumLineNotes:FlxTypedGroup<FlxSprite>;
    var playerStrums:FlxTypedGroup<FlxSprite>;
    private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public function new(daAnim:String = 'bf')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		CoolUtil.title('Camera debug');
		CoolUtil.presence(null, 'In camera debug', false, 0, null);

		this.bgColor = 0xffffff;

		camGame = new FlxCamera();

        camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camHUD);
		add(camHUD);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

        FlxG.camera.zoom = states.PlayState.stage.camZoom;

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0, 0); //gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		dad = new objects.Character(0, 0, daAnim);
		dad.debugMode = true;
        dad.playAnim('idle');
        dad.screenCenter();
		add(dad);

		char = dad;
		dad.flipX = false;

        strumLine = new FlxSprite(0, 0).makeGraphic(FlxG.width, 14);
		strumLine.scrollFactor.set();
        strumLine.alpha = 0.4;

        add(strumLine);
		
		if (data.KadeEngineData.settings.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

        strumLine.cameras = [camHUD];
        playerStrums.cameras = [camHUD];

        generateStaticArrows(0);
		generateStaticArrows(1);

		addHelpText();

		characters = Main.characters;

		var tabs = [{name: "Offsets", label: 'Offset menu'},];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.scrollFactor.set();
		UI_box.resize(150, 200);
		UI_box.x = FlxG.width - UI_box.width - 20;
		UI_box.y = 20;

		add(UI_box);

		var player1DropDown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
            {
                remove(dad);
                dad = new objects.Character(0, 0, characters[Std.parseInt(character)]);
                dad.screenCenter();
                dad.debugMode = true;
                dad.flipX = false;
                dad.playAnim('idle');
                add(dad);
    
                replace(char, dad);
                char = dad;
            });
    
            player1DropDown.selectedLabel = char.curCharacter;
    
            camOffsets = new FlxText(10, 50, 'X Cam Pos: 0\nX Char Pos: 0');

            charOffsets = new FlxText(10, 100, 'Y Cam Pos: 0\nY Char Pos: 0');

			zoomText = new FlxText(10, 10, 0, 'Zoom: 0', 32);
			zoomText.setPosition(10, 10);
			zoomText.scrollFactor.set();
			zoomText.color = FlxColor.RED;
			add(zoomText);
    
            var tab_group_offsets = new FlxUI(null, UI_box);
            tab_group_offsets.name = "Offsets";
    
            tab_group_offsets.add(camOffsets);
            tab_group_offsets.add(charOffsets);
            tab_group_offsets.add(player1DropDown);
    
            UI_box.addGroup(tab_group_offsets);

        cameraPoint = new FlxSprite().makeGraphic(1, 1, 0x00ff37);
        cameraPoint.screenCenter();
		cameraPoint.cameras = [camHUD, camGame];
        add(cameraPoint);

		//FlxG.cameras.reset(camHUD);
        camHUD.target = cameraPoint;
		camGame.target = cameraPoint;

		//FlxG.camera.follow(cameraPoint);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		super.create();
	}

	var helpText:FlxText;

	function addHelpText():Void
		{
			helpText = new FlxText(1000, 20, 0, Language.get('CameraDebug', 'help_text'), 15);
			helpText.scrollFactor.set();
			helpText.y = FlxG.height - helpText.height - 20;
			helpText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			helpText.color = FlxColor.WHITE;
	
			add(helpText);
		}

	var converted:Bool = true;

	var zoomText:FlxText;

	override function update(elapsed:Float)
	{
		zoomText.text = "Zoom: " + FlxG.camera.zoom;

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.05;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.05;

		if (FlxG.keys.justPressed.SPACE)
			converted = !converted;

		if (!converted)
		{
			//offsetXtxt.text = "X Cam Pos: " + Math.round(cameraPoint.x) + "\nX Char Pos: " + Math.round(dad.getGraphicMidpoint().x);
			//offsetYtxt.text = "Y Cam Pos: " + Math.round(cameraPoint.y) + "\nY Char Pos: " + Math.round(dad.getGraphicMidpoint().y);
			camOffsets.text = "X Cam Pos: " + Math.round(cameraPoint.x) + "\nY Cam Pos: " + Math.round(cameraPoint.y);
			charOffsets.text = "X Char Pos: " + Math.round(dad.getGraphicMidpoint().x) + "\nY Char Pos: " + Math.round(dad.getGraphicMidpoint().y);
		}
		else
		{
			//offsetXtxt.text = "X Cam Pos: " + Math.round(cameraPoint.x - dad.getGraphicMidpoint().x) + "\nX Char Pos: " + Math.round(dad.getGraphicMidpoint().x - dad.getGraphicMidpoint().x);
			//offsetYtxt.text = "Y Cam Pos: " + Math.round(cameraPoint.y - dad.getGraphicMidpoint().y) + "\nY Char Pos: " + Math.round(dad.getGraphicMidpoint().y - dad.getGraphicMidpoint().y);
			camOffsets.text = "X Cam Pos: " + Math.round(cameraPoint.x - dad.getGraphicMidpoint().x) + "\nY Cam Pos: " + Math.round(cameraPoint.y - dad.getGraphicMidpoint().y);
			charOffsets.text = "X Char Pos: " + Math.round(dad.getGraphicMidpoint().x - dad.getGraphicMidpoint().x) + "\nY Char Pos: " + Math.round(dad.getGraphicMidpoint().y - dad.getGraphicMidpoint().y);
		}

        for (i in playerStrums)
            i.y = strumLine.y;
        for (i in strumLineNotes)
            i.y = strumLine.y;

		if (FlxG.keys.justPressed.ESCAPE)
			funkin.MusicBeatState.switchState(new states.PlayState());

		if (FlxG.keys.justPressed.F)
		{
			char.flipX = !char.flipX;
		}

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				cameraPoint.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				cameraPoint.velocity.y = 90;
			else
				cameraPoint.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				cameraPoint.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				cameraPoint.velocity.x = 90;
			else
				cameraPoint.velocity.x = 0;
		}
		else
		{
			cameraPoint.velocity.set();
		}

		if (FlxG.keys.justPressed.F1)
			data.KadeEngineData.showHelp = !data.KadeEngineData.showHelp;

		helpText.text = (data.KadeEngineData.showHelp ? Language.get('CameraDebug', 'help_text') : Language.get('Global', 'debug_help_toggle'));

		super.update(elapsed);
	}

    private function generateStaticArrows(player:Int):Void
        {
            for (i in 0...4)
            {
                // FlxG.log.add(i);
                var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
                babyArrow.frames = Paths.getSparrowAtlas('gameplay/notes/NOTE_assets', 'shared');
                babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
                switch (Math.abs(i))
                {
                    case 0:
                        babyArrow.x += objects.Note.swagWidth * 0;
                        babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                    case 1:
                        babyArrow.x += objects.Note.swagWidth * 1;
                        babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                    case 2:
                        babyArrow.x += objects.Note.swagWidth * 2;
                        babyArrow.animation.addByPrefix('static', 'arrowUP');
                    case 3:
                        babyArrow.x += objects.Note.swagWidth * 3;
                        babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                }
                babyArrow.updateHitbox();
                babyArrow.scrollFactor.set();
    
                babyArrow.ID = i;
    
                if (player == 1)
                    playerStrums.add(babyArrow);
    
                babyArrow.animation.play('static');
                babyArrow.x += 50;
                babyArrow.x += ((FlxG.width / 2) * player);
    
                strumLineNotes.add(babyArrow);
            }
        }
}