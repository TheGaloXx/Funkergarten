package menus;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxBasic;
import flixel.system.FlxSound;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
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

class ImportantOptions extends MusicBeatState
{
	public static var instance:ImportantOptions;

	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

	var desc:String = "";

    var controlsButton:KinderButton;
    var fpsCap:KinderButton;
    var flashing:KinderButton;
    var language:KinderButton;
    var mechanic:KinderButton;

    public var acceptInput:Bool = true; //FOR KEYBINDS

    var normalCamZoom:Float = 1;

	override function create()
	{
		instance = this;

        #if debug
		flixel.addons.studio.FlxStudio.create();
		#end

		FlxG.mouse.visible = true;

		Application.current.window.title = (Main.appTitle + ' - Important Options Menu');

		//(cast (Lib.current.getChildAt(0), Main)).setFPSCap(120); bug de bajon de fps

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/menuDesat"));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);

        var paper:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/page'));
        paper.antialiasing = FlxG.save.data.antialiasing;
        paper.screenCenter();
        add(paper);

		desc = "none";

		versionShit = new FlxText(5, FlxG.height + 40, 0, desc, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.BLACK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		versionShit.borderSize = 1.25;
		
		blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 1500)), Std.int(versionShit.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.8;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});

        controlsButton = new KinderButton(207, 80, "", "");
        controlsButton.daText.x += 70;
        fpsCap = new KinderButton(407, 80, "", "");
        fpsCap.daText.x += 45;
        fpsCap.daText.size = 40;
        flashing = new KinderButton(207, 160, "", "");
        flashing.daText.x += 35;
        flashing.daText.size = 40;
        language = new KinderButton(407, 160, "", "");
        language.daText.x += 85;
        mechanic = new KinderButton(0, 240, "", "");
        mechanic.daText.x += 40;
        mechanic.screenCenter(X);

        add(controlsButton);
        add(fpsCap);
        add(flashing);
        add(language);
        add(mechanic);

        controlsButton.texto = (FlxG.save.data.esp ? "Controles" : "Controls");
        fpsCap.texto = (FlxG.save.data.esp ? "Limite de FPS: " : "Frame rate: ") + FlxG.save.data.fpsCap;
        flashing.texto = (FlxG.save.data.esp ? "Luces fuertes: " : "Flashing lights: ") + (FlxG.save.data.esp ? (FlxG.save.data.flashing ? 'Si' : 'No') : (FlxG.save.data.flashing ? 'On' : 'Off'));
        language.texto = (FlxG.save.data.esp ? "English" : "Espanol");
        mechanic.texto = (FlxG.save.data.esp ? "Mecanicas: " : "Mechanics: ") + (FlxG.save.data.esp ? (FlxG.save.data.mechanics ? 'Si' : 'No') : (FlxG.save.data.mechanics ? 'On' : 'Off'));

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        versionShit.text = desc;

        if (acceptInput) //KEYBINDS
            {
                if (canDoSomething)
                    {
                        #if debug
                        if (FlxG.mouse.pressedMiddle)
                            FlxG.camera.zoom = 0.4;
                        else
                            FlxG.camera.zoom = normalCamZoom;
                        #end

                        if (controls.BACK)
                            {
                                trace("backes in a epic way");
                                canDoSomething = false;
                                        
                                FlxG.switchState(new KindergartenOptions());
                             }
            
                        //what? messy code? what're u talking about?
                        //if you think this code is messy, you DONT want to know how it was before

                        if (controlsButton.selected)
                            {
                                desc = (FlxG.save.data.esp ? "Ajusta tus controles." : "Choose your controls.");
                                if (FlxG.mouse.justPressed)
                                {
                                    openSubState(new KeyBindMenu());
                                    trace("selected controls omg");
                                }
                            }
                        else if (fpsCap.selected)
                            {
                                desc = (FlxG.save.data.esp ? "Ajusta el limite de FPS." : "Change the FPS limit.");
                                if (FlxG.mouse.justPressed)
                                {
                                    FlxG.save.data.fpsCap += 60;
                                    if (FlxG.save.data.fpsCap > 240)
                                        FlxG.save.data.fpsCap = 60;

                                    trace("selected fps omg");
                                    fpsCap.texto = (FlxG.save.data.esp ? "Limite de FPS: " : "Frame rate: ") + FlxG.save.data.fpsCap;

                                    (cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
                                }
                            }
                        else if (flashing.selected)
                            {
                                desc = (FlxG.save.data.esp ? "Activa las luces parpadeantes que puedan causar daños a la vista o epilepsia." : "Toggle flashing lights that can cause epileptic seizures and strain.");
                                if (FlxG.mouse.justPressed)
                                {
                                    FlxG.save.data.flashing = !FlxG.save.data.flashing; 
                                    trace("selected flashing omg");
                                    flashing.texto = (FlxG.save.data.esp ? "Luces fuertes: " : "Flashing lights: ") + (FlxG.save.data.esp ? (FlxG.save.data.flashing ? 'Si' : 'No') : (FlxG.save.data.flashing ? 'On' : 'Off'));
                                }
                            }
                        else if (language.selected)
                            {
                                desc = (FlxG.save.data.esp ? "Cambia el idioma de espanol a ingles o viceversa." : "Changes the language from english to spanish or viceversa.");
                                if (FlxG.mouse.justPressed)
                                {
                                    FlxG.save.data.esp = !FlxG.save.data.esp; 
                                    trace("selected language omg");
                                    language.texto = (FlxG.save.data.esp ? "English" : "Espanol");
                                    FlxG.resetState();
                                }
                            }
                        else if (mechanic.selected)
                            {
                                desc = (FlxG.save.data.esp ? "Activa o desactiva las mecanicas que aumentan la dificultad." : "Toggle the mechanics that make the game harder.");
                                if (FlxG.mouse.justPressed)
                                {
                                    FlxG.save.data.mechanics = !FlxG.save.data.mechanics; 
                                    trace("selected mechanics omg");
                                    mechanic.texto = (FlxG.save.data.esp ? "Mecanicas: " : "Mechanics: ") + (FlxG.save.data.esp ? (FlxG.save.data.mechanics ? 'Si' : 'No') : (FlxG.save.data.mechanics ? 'On' : 'Off'));
                                }
                            }
                        else
                            desc = (FlxG.save.data.esp ? "Seleccione una opcion." : "Select an option.");
                    }
                    else
                        desc = "";
            }

		FlxG.save.flush();
	}
}
