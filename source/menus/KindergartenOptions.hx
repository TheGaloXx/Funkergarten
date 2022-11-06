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

class KindergartenOptions extends MusicBeatState
{
	public static var instance:KindergartenOptions;

	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

	var desc:String = "";

    var gameplay:KinderButton;
    var important:KinderButton;
    var appearance:KinderButton;
    var misc:KinderButton;

    var normalCamZoom:Float = 1;

	override function create()
	{
		instance = this;

        #if debug
		flixel.addons.studio.FlxStudio.create();
		#end

		FlxG.mouse.visible = true;

		Application.current.window.title = (Main.appTitle + ' - Options Menu');

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

        important = new KinderButton(0, 80, "", "");
        important.daText.x += 65;
        important.screenCenter(X);
        
        gameplay = new KinderButton(0, 140, "", "");
        gameplay.daText.x += 60;
        gameplay.screenCenter(X);

        appearance = new KinderButton(0, 200, "", "");
        appearance.daText.x += 60;
        appearance.screenCenter(X);

        misc = new KinderButton(0, 260, "", "");
        misc.daText.x += 100;
        misc.screenCenter(X);
        misc.x += 20;

        add(gameplay);
        add(important);
        add(appearance);
        add(misc);

        gameplay.texto = "Gameplay";
        important.texto = (FlxG.save.data.esp ? "Importante" : "Important");
        appearance.texto = (FlxG.save.data.esp ? "Apariencia" : "Appearance");
        misc.texto = (FlxG.save.data.esp ? "Otros" : "Misc");

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        versionShit.text = (FlxG.save.data.esp ? "Seleccione una categoria." : "Choose a category.");

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
                                
                        if (!substates.PauseSubState.options)
                        {
                            
                            FlxG.switchState(new MainMenuState());
                        }
                        else
                        {
                            substates.PauseSubState.options = false;
                                    
                            FlxG.switchState(new PlayState());
                        }
                     }
    
                //what? messy code? what're u talking about?
                //if you think this code is messy, you DONT want to know how it was before

                if (gameplay.selected)
                    {
                        if (FlxG.mouse.justPressed)
                        {
                            trace("selected gameplay omg");
                            FlxG.switchState(new GameplayOptions());
                        }
                    }
                else if (important.selected)
                    {
                        if (FlxG.mouse.justPressed)
                            {
                                trace("selected important omg");
                                FlxG.switchState(new ImportantOptions());
                            }
                    }
                else if (appearance.selected)
                    {
                        if (FlxG.mouse.justPressed)
                            {
                                trace("selected appearance omg");
                                FlxG.switchState(new AppearanceOptions());
                            }
                    }
                else if (misc.selected)
                    {
                        if (FlxG.mouse.justPressed)
                            {
                                trace("selected misc omg");
                                FlxG.switchState(new MiscOptions());
                            }
                    }
            }

		FlxG.save.flush();
	}
}
