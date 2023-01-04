package options;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import Objects.KinderButton;

class MiscOptions extends MusicBeatState
{
	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

    var buttons:FlxTypedGroup<KinderButton>;
    var fps:KinderButton;
    var snap:KinderButton;
    var scoreScreen:KinderButton;
    var botplay:KinderButton;
    var fullscreen:KinderButton;

	override function create()
	{
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

		versionShit = new FlxText(5, FlxG.height + 40, 0, "", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.BLACK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		versionShit.borderSize = 1.25;
		
		blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 1500)), Std.int(versionShit.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.8;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});

        addButtons();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (canDoSomething)
            {
                if (controls.BACK)
                    {
                        trace("backes in a epic way");
                        canDoSomething = false;
                                
                        FlxG.switchState(new KindergartenOptions());
                     }
    
                //what? messy code? what're u talking about?
                //if you think this code is messy, you DONT want to know how it was before
                //edit: code is way better now :cool:
                //ok that didnt work so i had to change it a little bit, but still way better than the first one
                //btw you spelt "wait" instead of "way" in the third comment, you suck bro

                if      (fps.selected)              versionShit.text = fps.description;
                else if (snap.selected)             versionShit.text = snap.description;
                else if (scoreScreen.selected)      versionShit.text = scoreScreen.description; 
                else if (botplay.selected)          versionShit.text = botplay.description;
                else if (fullscreen.selected)       versionShit.text = fullscreen.description;
                else                                versionShit.text = (FlxG.save.data.esp ? "Seleccione una opcion." : "Select an option.");
            }
            else
            {
                versionShit.text = "";

                buttons.forEach(function(button:KinderButton)
                    {
                        button.active = false;
                    });
            }

		FlxG.save.flush();
	}



    function addButtons():Void
    {
        buttons = new FlxTypedGroup<KinderButton>();
        add(buttons);



        //still pretty messy but at least way better than the old one :coolface:
        fps = new KinderButton(207 - 50, 80, "FPS: " + (FlxG.save.data.esp ? (FlxG.save.data.fps ? 'Mostrar' : 'Ocultar') : (FlxG.save.data.fps ? 'Show' : 'Hide')), (FlxG.save.data.esp ? "Muestra los FPS en la esquina superior de la pantalla." : "Toggle the FPS Counter."), function()   {   
            FlxG.save.data.fps = !FlxG.save.data.fps;
            (cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
            (cast (Lib.current.getChildAt(0), Main)).toggleMemCounter(FlxG.save.data.fps);
            trace("selected fps omg");
            fps.texto = "FPS: " + (FlxG.save.data.esp ? (FlxG.save.data.fps ? 'Mostrar' : 'Ocultar') : (FlxG.save.data.fps ? 'Show' : 'Hide'));
        });


        snap = new KinderButton(407 - 50, 80, (FlxG.save.data.esp ? "Chasquido: " : "Snap: ") + (FlxG.save.data.esp ? (FlxG.save.data.snap ? 'Si' : 'No') : (FlxG.save.data.snap ? 'On' : 'Off')), (FlxG.save.data.esp ? "Suena un chasquido al tocar una nota." : "Plays a snap sound when hitting a note."), function()    {
            FlxG.save.data.snap = !FlxG.save.data.snap; 
            trace("selected snap omg");
            snap.texto = (FlxG.save.data.esp ? "Chasquido: " : "Snap: ") + (FlxG.save.data.esp ? (FlxG.save.data.snap ? 'Si' : 'No') : (FlxG.save.data.snap ? 'On' : 'Off'));
        });


        scoreScreen = new KinderButton(207 - 50, 160, (FlxG.save.data.esp ? "P. resultados: " : "R. screen: ") + (FlxG.save.data.esp ? (FlxG.save.data.scoreScreen ? 'Si' : 'No') : (FlxG.save.data.scoreScreen ? 'On' : 'Off')), (FlxG.save.data.esp ? "Muestra una pantalla de resultados al terminar una cancion." : "Show the score screen after the end of a song."), function()    {
            FlxG.save.data.scoreScreen = !FlxG.save.data.scoreScreen; 
            trace("selected score screen mode omg");
            scoreScreen.texto = (FlxG.save.data.esp ? "P. resultados: " : "R. screen: ") + (FlxG.save.data.esp ? (FlxG.save.data.scoreScreen ? 'Si' : 'No') : (FlxG.save.data.scoreScreen ? 'On' : 'Off'));
        });


        botplay = new KinderButton(407 - 50, 160, "Botplay: " + (FlxG.save.data.esp ? (FlxG.save.data.botplay ? 'Si' : 'No') : (FlxG.save.data.botplay ? 'On' : 'Off')), (FlxG.save.data.esp ? "Activa un bot para que juegue automaticamente." : "Showcase your charts and mods with autoplay."), function()    {
            FlxG.save.data.botplay = !FlxG.save.data.botplay; 
            trace("selected botplay mode omg");
            botplay.texto = "Botplay: " + (FlxG.save.data.esp ? (FlxG.save.data.botplay ? 'Si' : 'No') : (FlxG.save.data.botplay ? 'On' : 'Off'));
        });
        

        fullscreen = new KinderButton(0, 240, (FlxG.save.data.fullscreen ? (FlxG.save.data.esp ? "En ventana" : "Windowed"): (FlxG.save.data.esp ? "Pantalla completa" : "Fullscreen")), (FlxG.save.data.esp ? "Cambia la pantalla de ventana a pantalla completa o viceversa." : "Toggle fullscreen or windowed."), function() {
            FlxG.save.data.fullscreen = !FlxG.save.data.fullscreen; 
            FlxG.fullscreen = FlxG.save.data.fullscreen;
            trace("selected fullscreen omg");
            fullscreen.texto = (FlxG.save.data.fullscreen ? (FlxG.save.data.esp ? "En ventana" : "Windowed"): (FlxG.save.data.esp ? "Pantalla completa" : "Fullscreen"));
        });
        fullscreen.screenCenter(X);


        /*add(fps);
        add(snap);
        add(scoreScreen);
        add(botplay);
        add(fullscreen);*/

        buttons.add(fps);
        buttons.add(snap);
        buttons.add(scoreScreen);
        buttons.add(botplay);
        buttons.add(fullscreen);
    }
}
