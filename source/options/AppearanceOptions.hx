package options;

import flixel.graphics.frames.FlxAtlasFrames;
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

class AppearanceOptions extends MusicBeatState
{
	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

    var buttons:FlxTypedGroup<KinderButton>;
    var antialiasing:KinderButton;
    var shaders:KinderButton;
    var camMove:KinderButton;
    var distractions:KinderButton;
    var accuracyDisplay:KinderButton;
    var songPosition:KinderButton;

    var tex:FlxAtlasFrames;
	var bf:FlxSprite;
	var a:FlxText;

	override function create()
	{
		FlxG.mouse.visible = true;

		Application.current.window.title = (Main.appTitle + ' - Appearance Options Menu');

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

        bf = new FlxSprite();
		var tex = Paths.getSparrowAtlas('characters/bf');
		bf.frames = tex;
		bf.animation.addByPrefix('idle', 'BF idle dance', 24, true);
		bf.scale.set(0.4, 0.4);
		bf.updateHitbox();
		bf.setPosition(FlxG.width - bf.width, FlxG.height - bf.height);
		bf.animation.play('idle', true);
		bf.visible = false;
        bf.antialiasing = FlxG.save.data.antialiasing;
		add(bf);

		a = new FlxText();
		a.alignment = CENTER;
		a.size = 25;
		a.x = 1046;
		a.y = 685.5;
		a.color = 0xffffffff;
		a.visible = false;
        a.antialiasing = FlxG.save.data.antialiasing;
        a.text = (FlxG.save.data.antialiasing ? "antialiasing on" : "antialiasing off");
		add(a);

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
                //yo what the fuck is this

                if (!antialiasing.selected) {   bf.visible = false;  a.visible = false;}

                if      (antialiasing.selected){    versionShit.text = antialiasing.description;    bf.visible = true; a.visible = true;    }
                else if (shaders.selected)          versionShit.text = shaders.description;
                else if (camMove.selected)          versionShit.text = camMove.description; 
                else if (distractions.selected)     versionShit.text = distractions.description;
                else if (accuracyDisplay.selected)  versionShit.text = accuracyDisplay.description;
                else if (songPosition.selected)     versionShit.text = songPosition.description;
                else                                versionShit.text = (FlxG.save.data.esp ? "Seleccione una opcion." : "Select an option.");
            }
            else
            {
                versionShit.text = "";

                bf.visible = false;  a.visible = false;

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
        antialiasing = new KinderButton(207 - 50, 80, "Antialiasing: " + (FlxG.save.data.esp ? (FlxG.save.data.antialiasing ? 'Si' : 'No') : (FlxG.save.data.antialiasing ? 'On' : 'Off')), (FlxG.save.data.esp ? "Si se deshabilita hay mejor rendimiento pero menor calidad de imagen." : "If disabled, the game works better but less image quality."), function()   {   
            FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing; 
            bf.antialiasing = FlxG.save.data.antialiasing;
            a.antialiasing = FlxG.save.data.antialiasing;
		    a.text = (FlxG.save.data.antialiasing ? "antialiasing on" : "antialiasing off");
            antialiasing.texto = "Antialiasing: " + (FlxG.save.data.esp ? (FlxG.save.data.antialiasing ? 'Si' : 'No') : (FlxG.save.data.antialiasing ? 'On' : 'Off'));
        });


        shaders = new KinderButton(407 - 50, 80, "Shaders: " + (FlxG.save.data.esp ? (FlxG.save.data.shaders ? 'Si' : 'No') : (FlxG.save.data.shaders ? 'On' : 'Off')), (FlxG.save.data.esp ? "Activa los shaders (bajo rendimiento)." : "Toggle shaders (low performance)."), function()    {
            FlxG.save.data.shaders = !FlxG.save.data.shaders; 
            shaders.texto = "Shaders: " + (FlxG.save.data.esp ? (FlxG.save.data.shaders ? 'Si' : 'No') : (FlxG.save.data.shaders ? 'On' : 'Off'));
        });


        camMove = new KinderButton(207 - 50, 160, (FlxG.save.data.esp ? "Movimiento Cam: " : "Cam Movement: ") + (FlxG.save.data.esp ? (FlxG.save.data.camMove ? 'Si' : 'No') : (FlxG.save.data.camMove ? 'On' : 'Off')), (FlxG.save.data.esp ? "Habilita que la camara se mueva segun la nota que toquen los personajes." : "Toggle camera movement when a character is singing."), function()    {
            FlxG.save.data.camMove = !FlxG.save.data.camMove; 
            camMove.texto = (FlxG.save.data.esp ? "Movimiento Cam: " : "Cam Movement: ") + (FlxG.save.data.esp ? (FlxG.save.data.camMove ? 'Si' : 'No') : (FlxG.save.data.camMove ? 'On' : 'Off'));
        });


        distractions = new KinderButton(407 - 50, 160, (FlxG.save.data.esp ? "Distracciones: " : "Distractions: ") + (FlxG.save.data.esp ? (FlxG.save.data.distractions ? 'Si' : 'No') : (FlxG.save.data.distractions ? 'On' : 'Off')), (FlxG.save.data.esp ? "Activa las distracciones que podrian molestar o bajar el rendimiento." : "Toggle stage distractions that can hinder your gameplay or decrease performance."), function()    {
            FlxG.save.data.distractions = !FlxG.save.data.distractions; 
            distractions.texto = (FlxG.save.data.esp ? "Distracciones: " : "Distractions: ") + (FlxG.save.data.esp ? (FlxG.save.data.distractions ? 'Si' : 'No') : (FlxG.save.data.distractions ? 'On' : 'Off'));
        });

        accuracyDisplay = new KinderButton(207 - 50, 240, (FlxG.save.data.esp ? "Precision: " : "Accuracy: ") + (FlxG.save.data.esp ? (FlxG.save.data.accuracyDisplay ? 'Si' : 'No') : (FlxG.save.data.accuracyDisplay ? 'On' : 'Off')), (FlxG.save.data.esp ? "Activa la informacion acerca de la precision." : "Display accuracy information."), function() {
            FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay; 
            accuracyDisplay.texto = (FlxG.save.data.esp ? "Precision: " : "Accuracy: ") + (FlxG.save.data.esp ? (FlxG.save.data.accuracyDisplay ? 'Si' : 'No') : (FlxG.save.data.accuracyDisplay ? 'On' : 'Off'));
        });

        songPosition = new KinderButton(407 - 50, 240, (FlxG.save.data.esp ? "Barra de progreso: " : "Song bar: ") + (FlxG.save.data.esp ? (FlxG.save.data.songPosition ? 'Si' : 'No') : (FlxG.save.data.songPosition ? 'On' : 'Off')), (FlxG.save.data.esp ? "Muestra el progreso de la cancion (en una barra)." : "Show the songs current position (as a bar)."), function() {
            FlxG.save.data.songPosition = !FlxG.save.data.songPosition; 
            songPosition.texto = (FlxG.save.data.esp ? "Barra de progreso: " : "Song bar: ") + (FlxG.save.data.esp ? (FlxG.save.data.songPosition ? 'Si' : 'No') : (FlxG.save.data.songPosition ? 'On' : 'Off'));
        });

        buttons.add(antialiasing);
        buttons.add(shaders);
        buttons.add(camMove);
        buttons.add(distractions);
        buttons.add(accuracyDisplay);
        buttons.add(songPosition);
    }
}
