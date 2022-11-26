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
import Objects.KinderButton;

class GameplayOptions extends MusicBeatState
{
	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

	var desc:String = "";

    var downscroll:KinderButton;
    var middlescroll:KinderButton;
    var practice:KinderButton;
    var customize:KinderButton;

    var normalCamZoom:Float = 1;

	override function create()
	{
        #if debug
		flixel.addons.studio.FlxStudio.create();
		#end

		FlxG.mouse.visible = true;

		Application.current.window.title = (Main.appTitle + ' - Gameplay Options Menu');

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

        downscroll = new KinderButton(207, 80, "", "");
        downscroll.daText.x += 60;
        middlescroll = new KinderButton(407, 80, "", "");
        middlescroll.daText.x += 45;
        middlescroll.daText.size = 40;
        practice = new KinderButton(207, 160, "", "");
        practice.daText.x += 35;
        practice.daText.size = 40;
        customize = new KinderButton(407, 160, "", "");
        customize.daText.x += 35;
        customize.daText.size = 35;

        add(downscroll);
        add(middlescroll);
        add(practice);
        add(customize);

        downscroll.texto = (FlxG.save.data.downscroll ? "Downscroll" : "Upscroll");
        middlescroll.texto = "Middlescroll: " + (FlxG.save.data.esp ? (FlxG.save.data.middlescroll ? 'Si' : 'No') : (FlxG.save.data.middlescroll ? 'On' : 'Off'));
        practice.texto = (FlxG.save.data.esp ? "Modo practica: " : "Practice mode: ") + (FlxG.save.data.esp ? (FlxG.save.data.practice ? 'Si' : 'No') : (FlxG.save.data.practice ? 'On' : 'Off'));
        customize.texto = (FlxG.save.data.esp ? "Personalizar gameplay" : "Customize gameplay");

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

                if (downscroll.selected)
                    {
                        desc = (FlxG.save.data.esp ? "Cambia si las notas suben o bajan." : "Change if the notes go up or down.");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.downscroll = !FlxG.save.data.downscroll; 
                            trace("selected downscroll omg");
                            downscroll.texto = (FlxG.save.data.downscroll ? "Downscroll" : "Upscroll");
                        }
                    }
                else if (middlescroll.selected)
                    {
                        desc = (FlxG.save.data.esp ? "Cambia la posicion de las notas al medio." : "Change the layout of the strumline to the center.");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll; 
                            trace("selected middlescroll omg");
                            middlescroll.texto = "Middlescroll: " + (FlxG.save.data.esp ? (FlxG.save.data.middlescroll ? 'Si' : 'No') : (FlxG.save.data.middlescroll ? 'On' : 'Off'));
                        }
                    }
                else if (practice.selected)
                    {
                        desc = (FlxG.save.data.esp ? "Si se activa no puedes morir." : "If enabled, you can't die... cheater.");
                        if (FlxG.mouse.justPressed)
                        {
                            FlxG.save.data.practice = !FlxG.save.data.practice; 
                            trace("selected practice mode omg");
                            practice.texto = (FlxG.save.data.esp ? "Modo practica: " : "Practice mode: ") + (FlxG.save.data.esp ? (FlxG.save.data.practice ? 'Si' : 'No') : (FlxG.save.data.practice ? 'On' : 'Off'));
                        }
                    }
                else if (customize.selected)
                    {
                        desc = (FlxG.save.data.esp ? "Mueve los sprite de combo a tu preferencia." : "Move Gameplay Modules around to your preference.");
                        if (FlxG.mouse.justPressed)
                            {
                                canDoSomething = false; 
                                trace("selected customize gameplay omg");
                                FlxG.switchState(new GameplayCustomizeState());
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
