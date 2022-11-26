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
import Objects.KinderButton;

class AppearanceOptions extends MusicBeatState
{
	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

	var desc:String = "";

	var tex:FlxAtlasFrames;
	var bf:FlxSprite;
	var a:FlxText;

    var antialiasing:KinderButton;
    var shaders:KinderButton;
    var camMove:KinderButton;
    var distractions:KinderButton;
    var accuracyDisplay:KinderButton;
    var songPosition:KinderButton;

    var normalCamZoom:Float = 1;

	override function create()
	{
        #if debug
		flixel.addons.studio.FlxStudio.create();
		#end

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

        antialiasing = new KinderButton(207, 80, "", "");
        antialiasing.daText.x += 40;
        antialiasing.daText.size = 45;
        shaders = new KinderButton(407, 80, "", "");
        shaders.daText.x += 60;
        camMove = new KinderButton(207, 160, "", "");
        camMove.daText.x += 35;
        camMove.daText.size = 35;
        distractions = new KinderButton(407, 160, "", "");
        distractions.daText.x += 40;
        distractions.daText.size = 40;
        accuracyDisplay = new KinderButton(207, 240, "", "");
        accuracyDisplay.daText.x += 40;
        songPosition = new KinderButton(407, 240, "", "");
        songPosition.daText.x += 40;
        songPosition.daText.size = 40;

        add(antialiasing);
        add(shaders);
        add(camMove);
        add(distractions);
        add(accuracyDisplay);
        add(songPosition);

        antialiasing.texto = "Antialiasing: " + (FlxG.save.data.esp ? (FlxG.save.data.antialiasing ? 'Si' : 'No') : (FlxG.save.data.antialiasing ? 'On' : 'Off'));
        shaders.texto = "Shaders: " + (FlxG.save.data.esp ? (FlxG.save.data.canAddShaders ? 'Si' : 'No') : (FlxG.save.data.canAddShaders ? 'On' : 'Off'));
        camMove.texto = (FlxG.save.data.esp ? "Movimiento Cam: " : "Cam Movement: ") + (FlxG.save.data.esp ? (FlxG.save.data.camMove ? 'Si' : 'No') : (FlxG.save.data.camMove ? 'On' : 'Off'));
        distractions.texto = (FlxG.save.data.esp ? "Distracciones: " : "Distractions: ") + (FlxG.save.data.esp ? (FlxG.save.data.distractions ? 'Si' : 'No') : (FlxG.save.data.distractions ? 'On' : 'Off'));
        accuracyDisplay.texto = (FlxG.save.data.esp ? "Precision: " : "Accuracy: ") + (FlxG.save.data.esp ? (FlxG.save.data.accuracyDisplay ? 'Si' : 'No') : (FlxG.save.data.accuracyDisplay ? 'On' : 'Off'));
        songPosition.texto = (FlxG.save.data.esp ? "Barra de progreso: " : "Song bar: ") + (FlxG.save.data.esp ? (FlxG.save.data.songPosition ? 'Si' : 'No') : (FlxG.save.data.songPosition ? 'On' : 'Off'));

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        bf.antialiasing = FlxG.save.data.antialiasing;
		a.text = (FlxG.save.data.antialiasing ? "antialiasing on" : "antialiasing off");

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

                if (antialiasing.selected)
                    {
                        bf.visible = true;
                        a.visible = true;
                        desc = (FlxG.save.data.esp ? "Si se deshabilita hay mejor rendimiento pero menor calidad de imagen." : "If disabled, the game works better but less image quality.");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing; 
                            trace("selected antialiasing omg");
                            antialiasing.texto = "Antialiasing: " + (FlxG.save.data.esp ? (FlxG.save.data.antialiasing ? 'Si' : 'No') : (FlxG.save.data.antialiasing ? 'On' : 'Off'));
                        }
                    }
                else if (shaders.selected)
                    {
                        bf.visible = false;
                        a.visible = false;
                        desc = (FlxG.save.data.esp ? "Activa los shaders (bajo rendimiento)." : "Toggle shaders (low performance).");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.canAddShaders = !FlxG.save.data.canAddShaders; 
                            trace("selected shaders omg");
                            shaders.texto = "Shaders: " + (FlxG.save.data.esp ? (FlxG.save.data.canAddShaders ? 'Si' : 'No') : (FlxG.save.data.canAddShaders ? 'On' : 'Off'));
                        }
                    }
                else if (camMove.selected)
                    {
                        bf.visible = false;
                        a.visible = false;
                        desc = (FlxG.save.data.esp ? "Habilita que la camara se mueva segun la nota que toquen los personajes." : "Toggle camera movement when a character is singing.");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.camMove = !FlxG.save.data.camMove; 
                            trace("selected cam move omg");
                            camMove.texto = (FlxG.save.data.esp ? "Movimiento Cam: " : "Cam Movement: ") + (FlxG.save.data.esp ? (FlxG.save.data.camMove ? 'Si' : 'No') : (FlxG.save.data.camMove ? 'On' : 'Off'));
                        }
                    }
                else if (distractions.selected)
                    {
                        bf.visible = false;
                        a.visible = false;
                        desc = (FlxG.save.data.esp ? "Activa las distracciones que podrian molestar o bajar el rendimiento." : "Toggle stage distractions that can hinder your gameplay or decrease performance.");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.distractions = !FlxG.save.data.distractions; 
                            trace("selected distractions omg");
                            distractions.texto = (FlxG.save.data.esp ? "Distracciones: " : "Distractions: ") + (FlxG.save.data.esp ? (FlxG.save.data.distractions ? 'Si' : 'No') : (FlxG.save.data.distractions ? 'On' : 'Off'));
                        }
                    }
                else if (accuracyDisplay.selected)
                    {
                        bf.visible = false;
                        a.visible = false;
                        desc = (FlxG.save.data.esp ? "Activa la informacion acerca de la precision." : "Display accuracy information.");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay; 
                            trace("selected accuracy omg");
                            accuracyDisplay.texto = (FlxG.save.data.esp ? "Precision: " : "Accuracy: ") + (FlxG.save.data.esp ? (FlxG.save.data.accuracyDisplay ? 'Si' : 'No') : (FlxG.save.data.accuracyDisplay ? 'On' : 'Off'));
                        }
                    }
                else if (songPosition.selected)
                    {
                        bf.visible = false;
                        a.visible = false;
                        desc = (FlxG.save.data.esp ? "Muestra el progreso de la cancion (en una barra)." : "Show the songs current position (as a bar).");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.songPosition = !FlxG.save.data.songPosition; 
                            trace("selected song position omg");
                            songPosition.texto = (FlxG.save.data.esp ? "Barra de progreso: " : "Song bar: ") + (FlxG.save.data.esp ? (FlxG.save.data.songPosition ? 'Si' : 'No') : (FlxG.save.data.songPosition ? 'On' : 'Off'));
                        }
                    }
                else{
                    desc = (FlxG.save.data.esp ? "Seleccione una opcion." : "Select an option.");
                    bf.visible = false;
                        a.visible = false;
                }
            }
            else{
                desc = "";
                bf.visible = false;
                a.visible = false;
            }

		FlxG.save.flush();
	}
}
