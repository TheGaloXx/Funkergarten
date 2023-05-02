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

        bf = new FlxSprite();
		var tex = Paths.getSparrowAtlas('characters/bf', 'shared');
		bf.frames = tex;
		bf.animation.addByPrefix('idle', 'BF idle dance', 24, true);
		bf.scale.set(0.4, 0.4);
		bf.updateHitbox();
		bf.setPosition(FlxG.width - bf.width, FlxG.height - bf.height);
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
        a.text = (KadeEngineData.settings.data.antialiasing ? "antialiasing on" : "antialiasing off");
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
                else                                versionShit.text = (KadeEngineData.settings.data.esp ? "Seleccione una opcion." : "Select an option.");
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

		KadeEngineData.flush(false);
	}



    function addButtons():Void
    {
        buttons = new FlxTypedGroup<KinderButton>();
        add(buttons);



        //still pretty messy but at least way better than the old one :coolface:
        antialiasing = new KinderButton(207 - 50, 80, "Antialiasing: " + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.antialiasing ? 'Si' : 'No') : (KadeEngineData.settings.data.antialiasing ? 'On' : 'Off')), (KadeEngineData.settings.data.esp ? "Si se deshabilita hay mejor rendimiento pero menor calidad de imagen." : "If disabled, the game works better but less image quality."), function()   {   
            KadeEngineData.settings.data.antialiasing = !KadeEngineData.settings.data.antialiasing; 
            flixel.FlxSprite.defaultAntialiasing = KadeEngineData.settings.data.antialiasing;
            bf.antialiasing = KadeEngineData.settings.data.antialiasing;
            a.antialiasing = KadeEngineData.settings.data.antialiasing;
		    a.text = (KadeEngineData.settings.data.antialiasing ? "antialiasing on" : "antialiasing off");
            antialiasing.texto = "Antialiasing: " + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.antialiasing ? 'Si' : 'No') : (KadeEngineData.settings.data.antialiasing ? 'On' : 'Off'));
        });


        shaders = new KinderButton(407 - 50, 80, "Shaders: " + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.shaders ? 'Si' : 'No') : (KadeEngineData.settings.data.shaders ? 'On' : 'Off')), (KadeEngineData.settings.data.esp ? "Activa los shaders (bajo rendimiento)." : "Toggle shaders (low performance)."), function()    {
            KadeEngineData.settings.data.shaders = !KadeEngineData.settings.data.shaders; 
            shaders.texto = "Shaders: " + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.shaders ? 'Si' : 'No') : (KadeEngineData.settings.data.shaders ? 'On' : 'Off'));
        });


        camMove = new KinderButton(207 - 50, 160, (KadeEngineData.settings.data.esp ? "Movimiento Cam: " : "Cam Movement: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.camMove ? 'Si' : 'No') : (KadeEngineData.settings.data.camMove ? 'On' : 'Off')), (KadeEngineData.settings.data.esp ? "Habilita que la camara se mueva segun la nota que toquen los personajes." : "Toggle camera movement when a character is singing."), function()    {
            KadeEngineData.settings.data.camMove = !KadeEngineData.settings.data.camMove; 
            camMove.texto = (KadeEngineData.settings.data.esp ? "Movimiento Cam: " : "Cam Movement: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.camMove ? 'Si' : 'No') : (KadeEngineData.settings.data.camMove ? 'On' : 'Off'));
        });


        distractions = new KinderButton(407 - 50, 160, (KadeEngineData.settings.data.esp ? "Distracciones: " : "Distractions: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.distractions ? 'Si' : 'No') : (KadeEngineData.settings.data.distractions ? 'On' : 'Off')), (KadeEngineData.settings.data.esp ? "Activa las distracciones que podrian molestar o bajar el rendimiento." : "Toggle stage distractions that can hinder your gameplay or decrease performance."), function()    {
            KadeEngineData.settings.data.distractions = !KadeEngineData.settings.data.distractions; 
            distractions.texto = (KadeEngineData.settings.data.esp ? "Distracciones: " : "Distractions: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.distractions ? 'Si' : 'No') : (KadeEngineData.settings.data.distractions ? 'On' : 'Off'));
        });

        accuracyDisplay = new KinderButton(207 - 50, 240, (KadeEngineData.settings.data.esp ? "Precision: " : "Accuracy: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.accuracyDisplay ? 'Si' : 'No') : (KadeEngineData.settings.data.accuracyDisplay ? 'On' : 'Off')), (KadeEngineData.settings.data.esp ? "Activa la informacion acerca de la precision." : "Display accuracy information."), function() {
            KadeEngineData.settings.data.accuracyDisplay = !KadeEngineData.settings.data.accuracyDisplay; 
            accuracyDisplay.texto = (KadeEngineData.settings.data.esp ? "Precision: " : "Accuracy: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.accuracyDisplay ? 'Si' : 'No') : (KadeEngineData.settings.data.accuracyDisplay ? 'On' : 'Off'));
        });

        songPosition = new KinderButton(407 - 50, 240, (KadeEngineData.settings.data.esp ? "Barra de progreso: " : "Song bar: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.songPosition ? 'Si' : 'No') : (KadeEngineData.settings.data.songPosition ? 'On' : 'Off')), (KadeEngineData.settings.data.esp ? "Muestra el progreso de la cancion (en una barra)." : "Show the songs current position (as a bar)."), function() {
            KadeEngineData.settings.data.songPosition = !KadeEngineData.settings.data.songPosition; 
            songPosition.texto = (KadeEngineData.settings.data.esp ? "Barra de progreso: " : "Song bar: ") + (KadeEngineData.settings.data.esp ? (KadeEngineData.settings.data.songPosition ? 'Si' : 'No') : (KadeEngineData.settings.data.songPosition ? 'On' : 'Off'));
        });

        buttons.add(antialiasing);
        buttons.add(shaders);
        buttons.add(camMove);
        buttons.add(distractions);
        buttons.add(accuracyDisplay);
        buttons.add(songPosition);
    }
}
