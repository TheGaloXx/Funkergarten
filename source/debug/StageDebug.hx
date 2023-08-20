package debug;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import lime.app.Application;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;

using StringTools;

//ENG
//To use this first press 7 in a song to open the chart editor, then select your stage in "stage", then enter or escape to close the editor and press 8 to open this StageDebug
//Theres a little tutorial: https://drive.google.com/file/d/1BdkdIpQ07_I5lfT12G9nrqNeYZ1vkAfX/view?usp=sharing
//F2 to open/close the debugger
//Ctrl + click or double click if theres two objects selected and you want to deselect one

//ESP
//Para usar esto primero presiona 7 en una cancion para abrir el editor de chart, despues elige tu escenario en "escenario", despues presione escape o enter para salir del editor, y presione 8 para abrir este editor de escenario
//Tutorial corto: https://drive.google.com/file/d/1BdkdIpQ07_I5lfT12G9nrqNeYZ1vkAfX/view?usp=sharing
//F2 para abrir/cerrar el debugger
//Ctrl + click o doble click si hay dos objetos seleccionados y quieres deseleccionar uno

class StageDebug extends funkin.MusicBeatState
{
    var curStage:String = 'stage';
    var stage:objects.Stage;
    #if GF var gf:objects.Character; #end
	var dad:objects.Character;
	var thirdCharacter:objects.Character;
	var bf:objects.Boyfriend;
	var camFollow:FlxObject;

	public function new(curStage:String = 'stage')
	{
		super();
		this.curStage = curStage;
	}

	override function create()
	{	
		CoolUtil.title('objects.Stage Debug');
		CoolUtil.presence(null, 'In stage debug', false, 0, null);

        FlxG.camera.zoom -= 0.5;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0, 0); //gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

        stage = new objects.Stage(curStage);
        add(stage);

		#if GF
        gf = new objects.Character(stage.positions['gf'][0], stage.positions['gf'][1], states.PlayState.gf.curCharacter);
		gf.debugMode = true;
		add(gf);
		#end

		dad = new objects.Character(stage.positions['dad'][0], stage.positions['dad'][1], states.PlayState.dad.curCharacter);
		dad.debugMode = true;
		add(dad);

		if (states.PlayState.songHas3Characters)
			{
				thirdCharacter = new objects.Character(stage.positions['third'][0], stage.positions['third'][1], states.PlayState.thirdCharacter.curCharacter);
				thirdCharacter.debugMode = true;
				add(thirdCharacter);
			}

		dad.flipX = false;

		bf = new objects.Boyfriend(stage.positions['bf'][0], stage.positions['bf'][1], states.PlayState.boyfriend.curCharacter);
		bf.debugMode = true;
		add(bf);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

        addHelpText();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
			funkin.MusicBeatState.switchState(new states.PlayState());

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

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
		{
			camFollow.velocity.set();
		}

        if (FlxG.keys.justPressed.F1)
			data.KadeEngineData.showHelp = !data.KadeEngineData.showHelp;

		helpText.text = (data.KadeEngineData.showHelp ? Language.get('StageDebug', 'help_text') : Language.get('Global', 'debug_help_toggle'));

		super.update(elapsed);
	}

    var helpText:FlxText;

	function addHelpText():Void
	{
		helpText = new FlxText(940, 20, 0, Language.get('StageDebug', 'help_text'), 15);
		helpText.scrollFactor.set();
		helpText.y = FlxG.height - helpText.height - 20;
		helpText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		helpText.color = FlxColor.WHITE;

		add(helpText);
	}
}