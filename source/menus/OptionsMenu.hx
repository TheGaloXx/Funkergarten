package menus;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxBasic;
import flixel.system.FlxSound;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import menus.Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var curSelected:Int = 0;

	var options:Array<OptionCategory> = (FlxG.save.data.esp ? [
		new OptionCategory("Importante", [
			new DFJKOption(controls, "Ajusta los controles."),
			#if cpp
			new FPSCapOption("."),
			#end
			new FlashingLightsOption("Activa las luces parpadeantes que puedan causar daños a la vista o epilepsia."),
			new Language("Cambia el idioma de español a ingles o viceversa."),
			new Mechanics("Activa o desactiva las mecanicas que aumentan la dificultad."),
		]),
		new OptionCategory("Gameplay", [
			new DownscrollOption("Cambia si las notas suben o bajan."),
			new MiddleScroll("Cambia la posicion de las notas al medio."),
			new GhostTapOption("El Ghost Tapping hace que puedas tocar las teclas sin que cuenten los fallos (New Input)."),
			new PracticeMode("Si se activa no puedes morir."),
			new Judgement("Personaliza el timing de las notas (IZQUIERDA or DERECHA)."),
			new ScrollSpeedOption(" - (1 = Fiel al chart)."),
			new CustomizeGameplay("Mueve los sprite de combo a tu preferencia.")
		]),
		new OptionCategory("Apariencia", [
			new AntialiasingOption("Si se deshabilita hay mejor rendimiento pero menor calidad de imagen."),
			new ShadersOption("Activa los shaders (bajo rendimiento)."),
			new CamMovement("Habilita que la camara se mueva segun la nota que toquen los personajes."),
			new DistractionsAndEffectsOption("Activa las distracciones que podrian molestar o bajar el rendimiento."),
			#if cpp
			new AccuracyOption("Activa la informacion acerca de la precision."),
			new SongPositionOption("Muestra la posicion de la cancion (en una barra)."),
			#end
		]),
		
		new OptionCategory("Otros", [
			#if cpp
			new FPSOption("Muestra los FPS en la esquina superior de la pantalla."),
			#end
			new SnapOption("Suena un chasquido al tocar una nota."),
			new ScoreScreen("Muestra una pantalla de resultados al terminar una cancion."),
			new BotPlay("Activa un bot para que juegue automaticamente."),
		])
		
	] : [
		new OptionCategory("Important", [
			new DFJKOption(controls, "Controls."),
			#if cpp
			new FPSCapOption("."),
			#end
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new Language("Changes the language from english to spanish or viceversa."),
			new Mechanics("Toggle the mechanics that make the game harder."),
		]),
		new OptionCategory("Gameplay", [
			new DownscrollOption("Change the layout of the strumline."),
			new MiddleScroll("Change the layout of the strumline to the center."),
			new GhostTapOption("Ghost Tapping is when you tap a direction and it doesn't give you a miss."),
			new PracticeMode("If enabled, you can't die... cheater."),
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
			new ScrollSpeedOption(" - (1 = Chart dependent)"),
			new CustomizeGameplay("Move Gameplay Modules around to your preference.")
		]),
		new OptionCategory("Appearance", [
			new AntialiasingOption("If disabled, the game works better but less image quality."),
			new ShadersOption("Toggle shaders (low performance)."),
			new CamMovement("Toggle camera movement when a character is singing."),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay or decrease performance."),
			#if cpp
			new AccuracyOption("Display accuracy information."),
			new SongPositionOption("Show the songs current position (as a bar)"),
			#end
		]),
		
		new OptionCategory("Misc", [
			#if cpp
			new FPSOption("Toggle the FPS Counter"),
			#end
			new SnapOption("Plays a snap sound when hitting a note."),
			new ScoreScreen("Show the score screen after the end of a song."),
			new BotPlay("Showcase your charts and mods with autoplay."),
		])
		
	]);

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;

	var descripcion:String = "Description: ";
	var desc2:String = "";

	var tex:FlxAtlasFrames;
	var bf:FlxSprite;
	var a:FlxText;
	
	override function create()
	{
		instance = this;

		//descripcion = (FlxG.save.data.esp ? "Descripcion: " : "Description: ");
		//desc2 = (FlxG.save.data.esp ? " - Descripcion: " : " - Description: ");

		

		descripcion = "";
		desc2 = " ";

		Application.current.window.title = (Main.appTitle + ' - Options Menu');

		//(cast (Lib.current.getChildAt(0), Main)).setFPSCap(120); bug de bajon de fps

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false, true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET()!
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height + 40, 0, descripcion + currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.BLACK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		versionShit.borderSize = 1.25;
		
		blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 1500)), Std.int(versionShit.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.8;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});


		//gotta fix this, it works only when you entered a song first
		bf = new FlxSprite();
		var tex = Paths.getSparrowAtlas('characters/bf');
		bf.frames = tex;
		bf.animation.addByPrefix('idle', 'BF idle dance', 24, true);
		bf.scale.set(0.6, 0.6);
		bf.updateHitbox();
		bf.screenCenter(Y);
		bf.x = 1033;
		bf.y = 443.5;
		bf.animation.play('idle', true);
		bf.visible = false;
		add(bf);

		a = new FlxText();
		a.alignment = CENTER;
		a.size = 25;
		a.x = 1046;
		a.y = 685.5;
		a.color = 0xffffffff;
		a.visible = false;
		add(a);

		super.create();
	}

	//BRO isCat STANDS FOR CATEGORY IM SO FUCKING STUPID
	var isCat:Bool = false;
	

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		bf.antialiasing = FlxG.save.data.antialiasing;
		a.text = (FlxG.save.data.antialiasing ? "antialiasing on" : "antialiasing off");

		if (acceptInput)
		{
			if (controls.BACK && !isCat)
			{
				if (!substates.PauseSubState.options){
					
					FlxG.switchState(new MainMenuState());
				}
				else
				{
					substates.PauseSubState.options = false;
					
					FlxG.switchState(new PlayState());
				}
			}
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0...options.length)
				{
					var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					grpControls.add(controlLabel);
					// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				}
				
				curSelected = 0;
				
				changeSelection(curSelected);
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(1);
				}
			}
			
			if (FlxG.keys.justPressed.UP)
				changeSelection(-1);
			if (FlxG.keys.justPressed.DOWN)
				changeSelection(1);
			
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].isAntialiasingOption)
					{
						bf.visible = true;
						a.visible = true;
					}
				else
					{
						bf.visible = false;
						a.visible = false;
					}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT && !currentSelectedCat.getOptions()[curSelected].allowFastChange)
						{
							if (FlxG.keys.pressed.RIGHT)
								currentSelectedCat.getOptions()[curSelected].right();
							if (FlxG.keys.pressed.LEFT)
								currentSelectedCat.getOptions()[curSelected].left();
							FlxG.save.flush();
						}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else
				{	
					versionShit.text = descripcion + currentDescription;
				}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + desc2 + currentDescription;
				else
					versionShit.text = descripcion + currentDescription;
			}
			else
			{
				
				versionShit.text = descripcion + currentDescription;
			}

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) {
						grpControls.members[curSelected].reType(currentSelectedCat.getOptions()[curSelected].getDisplay());
						trace(currentSelectedCat.getOptions()[curSelected].getDisplay());
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}
					curSelected = 0;
				}
				
				changeSelection();
			}
		}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{	
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + desc2 + currentDescription;
			else
				versionShit.text = descripcion + currentDescription;
		}
		else
			versionShit.text = descripcion + currentDescription;
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	public static function reiniciar():Void
		{
			FlxG.resetState();
		}
}
