package menus;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class MiscOptions extends MusicBeatState
{
	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

	var desc:String = "";
    var fps:KinderButton;
    var snap:KinderButton;
    var scoreScreen:KinderButton;
    var botplay:KinderButton;
    var fullscreen:KinderButton;

    var normalCamZoom:Float = 1;

	override function create()
	{
        #if debug
		flixel.addons.studio.FlxStudio.create();
		#end

		FlxG.mouse.visible = true;

		Application.current.window.title = (Main.appTitle + ' - Misc Options Menu');

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

        fps = new KinderButton(207, 80, "", "");
        fps.daText.x += 60;
        snap = new KinderButton(407, 80, "", "");
        snap.daText.x += 60;
        scoreScreen = new KinderButton(207, 160, "", "");
        scoreScreen.daText.x += 50;
        scoreScreen.daText.size = 45;
        botplay = new KinderButton(407, 160, "", "");
        botplay.daText.x += 50;
        fullscreen = new KinderButton(0, 240, "", "");
        fullscreen.daText.x += 40;
        fullscreen.screenCenter(X);

        add(fps);
        add(snap);
        add(scoreScreen);
        add(botplay);
        add(fullscreen);

        fps.texto = "FPS: " + (FlxG.save.data.esp ? (FlxG.save.data.fps ? 'Mostrar' : 'Ocultar') : (FlxG.save.data.fps ? 'Show' : 'Hide'));
        snap.texto = (FlxG.save.data.esp ? "Chasquido: " : "Snap: ") + (FlxG.save.data.esp ? (FlxG.save.data.snap ? 'Si' : 'No') : (FlxG.save.data.snap ? 'On' : 'Off'));
        scoreScreen.texto = (FlxG.save.data.esp ? "P. resultados: " : "R. screen: ") + (FlxG.save.data.esp ? (FlxG.save.data.scoreScreen ? 'Si' : 'No') : (FlxG.save.data.scoreScreen ? 'On' : 'Off'));
        botplay.texto = "Botplay: " + (FlxG.save.data.esp ? (FlxG.save.data.botplay ? 'Si' : 'No') : (FlxG.save.data.botplay ? 'On' : 'Off'));
        fullscreen.texto = (FlxG.save.data.fullscreen ? (FlxG.save.data.esp ? "En ventana" : "Windowed"): (FlxG.save.data.esp ? "Pantalla completa" : "Fullscreen"));

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        versionShit.text = desc;

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

                if (fps.selected)
                    {
                        desc = (FlxG.save.data.esp ? "Muestra los FPS en la esquina superior de la pantalla." : "Toggle the FPS Counter.");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.fps = !FlxG.save.data.fps;
                            (cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
                            trace("selected fps omg");
                            fps.texto = "FPS: " + (FlxG.save.data.esp ? (FlxG.save.data.fps ? 'Mostrar' : 'Ocultar') : (FlxG.save.data.fps ? 'Show' : 'Hide'));
                        }
                    }
                else if (snap.selected)
                    {
                        desc = (FlxG.save.data.esp ? "Suena un chasquido al tocar una nota." : "Plays a snap sound when hitting a note.");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.snap = !FlxG.save.data.snap; 
                            trace("selected snap omg");
                            snap.texto = (FlxG.save.data.esp ? "Chasquido: " : "Snap: ") + (FlxG.save.data.esp ? (FlxG.save.data.snap ? 'Si' : 'No') : (FlxG.save.data.snap ? 'On' : 'Off'));
                        }
                    }
                else if (scoreScreen.selected)
                    {
                        desc = (FlxG.save.data.esp ? "Muestra una pantalla de resultados al terminar una cancion." : "Show the score screen after the end of a song.");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.scoreScreen = !FlxG.save.data.scoreScreen; 
                            trace("selected score screen mode omg");
                            scoreScreen.texto = (FlxG.save.data.esp ? "P. resultados: " : "R. screen: ") + (FlxG.save.data.esp ? (FlxG.save.data.scoreScreen ? 'Si' : 'No') : (FlxG.save.data.scoreScreen ? 'On' : 'Off'));
                        }
                    }
                else if (botplay.selected)
                    {
                        desc = (FlxG.save.data.esp ? "Activa un bot para que juegue automaticamente." : "Showcase your charts and mods with autoplay.");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.botplay = !FlxG.save.data.botplay; 
                            trace("selected score screen mode omg");
                            botplay.texto = "Botplay: " + (FlxG.save.data.esp ? (FlxG.save.data.botplay ? 'Si' : 'No') : (FlxG.save.data.botplay ? 'On' : 'Off'));
                        }
                    }
                else if (fullscreen.selected)
                            {
                                desc = (FlxG.save.data.esp ? "Cambia la pantalla de ventana a pantalla completa o viceversa." : "Toggle fullscreen or windowed.");
                                if (FlxG.mouse.justPressed)
                                {
                                    FlxG.save.data.fullscreen = !FlxG.save.data.fullscreen; 
                                    FlxG.fullscreen = FlxG.save.data.fullscreen;
                                    trace("selected fullscreen omg");
                                    fullscreen.texto = (FlxG.save.data.fullscreen ? (FlxG.save.data.esp ? "En ventana" : "Windowed"): (FlxG.save.data.esp ? "Pantalla completa" : "Fullscreen"));
                                }
                            }
                else
                    desc = (FlxG.save.data.esp ? "Seleccione una opcion." : "Select an option.");
            }
            else
                desc = "";

		FlxG.save.flush();
	}
}
