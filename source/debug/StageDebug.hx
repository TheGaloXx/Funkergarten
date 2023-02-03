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

class StageDebug extends MusicBeatState
{
    var curStage:String = 'stage';
    var stage:Stage;
    var gf:Character;
	var dad:Character;
	var thirdCharacter:Character;
	var bf:Boyfriend;
	var camFollow:FlxObject;
    var helpTextValue = "Help:\nQ/E : Zoom in and out\nI/J/K/L : Move Camera\nEnter/ESC : Exit\nPress F1 to hide/show this!\n(For detailed information\ncheck at the start of StageDebug.hx)\n";
	var textoAyuda = "Ayuda:\nQ/E : Zoom menos o mas\nI/J/K/L : Mover Camara\nEnter/ESC : Salir\nF1 para ocultar/mostrar esto!\n(Para informacion mas detallada\nver el principio de StageDebug.hx)\n";

	public function new(curStage:String = 'stage')
	{
		super();
		this.curStage = curStage;
	}

	override function create()
	{	
		Application.current.window.title = (Main.appTitle + (FlxG.save.data.esp ? ' - Control De Escenario' : ' - Stage Debug'));

        FlxG.camera.zoom -= 0.5;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0, 0); //gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		FlxG.mouse.visible = true;

        stage = new Stage(curStage);
        add(stage);

        gf = new Character(stage.positions['gf'][0], stage.positions['gf'][1], PlayState.gf.curCharacter);
		gf.debugMode = true;
		add(gf);

		dad = new Character(stage.positions['dad'][0], stage.positions['dad'][1], PlayState.dad.curCharacter);
		dad.debugMode = true;
		add(dad);

		if (PlayState.songHas3Characters)
			{
				thirdCharacter = new Character(stage.positions['third'][0], stage.positions['third'][1], PlayState.thirdCharacter.curCharacter);
				thirdCharacter.debugMode = true;
				add(thirdCharacter);
			}

		dad.flipX = false;

		bf = new Boyfriend(stage.positions['bf'][0], stage.positions['bf'][1], PlayState.boyfriend.curCharacter);
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
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new PlayState());
		}

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
			FlxG.save.data.showHelp = !FlxG.save.data.showHelp;

		helpText.text = (FlxG.save.data.showHelp ? (FlxG.save.data.esp ? textoAyuda : helpTextValue) : (FlxG.save.data.esp ? "F1 - Ayuda" : "F1 - help"));

		super.update(elapsed);
	}

    var helpText:FlxText;

	function addHelpText():Void
	{
		helpText = new FlxText(940, 20, 0, (FlxG.save.data.esp ? textoAyuda : helpTextValue), 15);
		helpText.scrollFactor.set();
		helpText.y = FlxG.height - helpText.height - 20;
		helpText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		helpText.color = FlxColor.WHITE;

		add(helpText);
	}
}