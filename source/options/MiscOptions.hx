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
import Objects.KinderButton;

class MiscOptions extends MusicBeatState
{
	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

    var buttons:FlxTypedGroup<KinderButton>;
    var fps:KinderButton;
    var snap:KinderButton;
    var botplay:KinderButton;
    var fullscreen:KinderButton;
    var lockSong:KinderButton;

	override function create()
	{
		var time = Date.now().getHours();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/paper', 'preload'));
		bg.active = false;
		if (time > 19 || time < 8)
			bg.alpha = 0.7;
		add(bg);

        var paper:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/page', 'preload'));
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
                                
                        MusicBeatState.switchState(new KindergartenOptions());
                    }
    
                //what? messy code? what're u talking about?
                //if you think this code is messy, you DONT want to know how it was before
                //edit: code is way better now :cool:
                //ok that didnt work so i had to change it a little bit, but still way better than the first one
                //btw you spelt "wait" instead of "way" in the third comment, you suck bro

                if      (fps.selected)              versionShit.text = fps.description;
                else if (snap.selected)             versionShit.text = snap.description;
                else if (botplay.selected)          versionShit.text = botplay.description;
                else if (fullscreen.selected)       versionShit.text = fullscreen.description;
                else if (lockSong.selected)         versionShit.text = lockSong.description;
                else                                versionShit.text = (KadeEngineData.settings.data.esp ? "Seleccione una opcion." : "Select an option.");
            }
            else
            {
                versionShit.text = "";

                buttons.forEach(function(button:KinderButton)
                    {
                        button.active = false;
                    });
            }

            KadeEngineData.flush(false);
	}



    function addButtons():Void
    {
        buttons = new FlxTypedGroup<KinderButton>();
        add(buttons);



        //still pretty messy but at least way better than the old one :coolface:
        fps = new KinderButton(207 - 50, 80, "FPS: " + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.fps ? 'Mostrar' : 'Ocultar') : (KadeEngineData.settings.data.fps ? 'Show' : 'Hide')), (KadeEngineData.settings.data.esp ? "Muestra los FPS en la esquina superior de la pantalla." : "Toggle the FPS Counter."), function()   {   
            KadeEngineData.settings.data.fps = !KadeEngineData.settings.data.fps;
            (cast (Lib.current.getChildAt(0), Main)).toggleFPS(KadeEngineData.settings.data.fps);
            trace("selected fps omg");
            fps.texto = "FPS: " + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.fps ? 'Mostrar' : 'Ocultar') : (KadeEngineData.settings.data.fps ? 'Show' : 'Hide'));
        });


        snap = new KinderButton(407 - 50, 80, (KadeEngineData.settings.data.esp ? "Chasquido: " : "Snap: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.snap ? 'Si' : 'No') : (KadeEngineData.settings.data.snap ? 'On' : 'Off')), (KadeEngineData.settings.data.esp ? "Suena un chasquido al tocar una nota." : "Plays a snap sound when hitting a note."), function()    {
            KadeEngineData.settings.data.snap = !KadeEngineData.settings.data.snap; 
            trace("selected snap omg");
            snap.texto = (KadeEngineData.settings.data.esp ? "Chasquido: " : "Snap: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.snap ? 'Si' : 'No') : (KadeEngineData.settings.data.snap ? 'On' : 'Off'));
        });


        botplay = new KinderButton(207 - 50, 160, "Botplay: " + (KadeEngineData.settings.data.esp ? (KadeEngineData.botplay ? 'Si' : 'No') : (KadeEngineData.botplay ? 'On' : 'Off')), (KadeEngineData.settings.data.esp ? "Activa un bot para que juegue automaticamente." : "Showcase your charts and mods with autoplay."), function()    {
            KadeEngineData.botplay = !KadeEngineData.botplay; 
            trace("selected botplay mode omg");
            botplay.texto = "Botplay: " + (KadeEngineData.settings.data.esp ? (KadeEngineData.botplay ? 'Si' : 'No') : (KadeEngineData.botplay ? 'On' : 'Off'));
        });
        

        fullscreen = new KinderButton(407 - 50, 160, (KadeEngineData.settings.data.fullscreen ? (KadeEngineData.settings.data.esp ? "En ventana" : "Windowed"): (KadeEngineData.settings.data.esp ? "Pantalla completa" : "Fullscreen")), (KadeEngineData.settings.data.esp ? "Cambia la pantalla de ventana a pantalla completa o viceversa." : "Toggle fullscreen or windowed."), function() {
            KadeEngineData.settings.data.fullscreen = !KadeEngineData.settings.data.fullscreen; 
            FlxG.fullscreen = KadeEngineData.settings.data.fullscreen;
            trace("selected fullscreen omg");
            fullscreen.texto = (KadeEngineData.settings.data.fullscreen ? (KadeEngineData.settings.data.esp ? "En ventana" : "Windowed"): (KadeEngineData.settings.data.esp ? "Pantalla completa" : "Fullscreen"));
        });

        lockSong = new KinderButton(0, 240, (KadeEngineData.settings.data.esp ? "Bloquear v. canciones: " : "Lock Songs v.: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.songPosition ? 'Si' : 'No') : (KadeEngineData.settings.data.lockSong ? 'On' : 'Off')), (KadeEngineData.settings.data.esp ? "Evita que el volumen de la musica afecte a las voces e instrumental de las canciones." : "Lock the volume of the music to affect the voices and instrumental of the songs."), function() {
            KadeEngineData.settings.data.lockSong = !KadeEngineData.settings.data.lockSong; 
            lockSong.texto = (KadeEngineData.settings.data.esp ? "Bloquear v. canciones: " : "Lock Songs v.: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.lockSong ? 'Si' : 'No') : (KadeEngineData.settings.data.lockSong ? 'On' : 'Off'));
        });
        lockSong.screenCenter(X);


        /*add(fps);
        add(snap);
        add(botplay);
        add(fullscreen);
        add(lockSong);*/

        buttons.add(fps);
        buttons.add(snap);
        buttons.add(botplay);
        buttons.add(fullscreen);
        buttons.add(lockSong);
    }
}
