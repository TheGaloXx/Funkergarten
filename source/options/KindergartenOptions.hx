package options;

import flixel.group.FlxGroup.FlxTypedGroup;
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

class KindergartenOptions extends MusicBeatState
{
    public static var instance:KindergartenOptions;

	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

    var buttons:FlxTypedGroup<KinderButton>;
    var gameplay:KinderButton;
    var important:KinderButton;
    var appearance:KinderButton;
    var misc:KinderButton;
    
	override function create()
	{
        instance = this;

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
                                
                        if (!substates.PauseSubState.options)
                        {
                            MusicBeatState.switchState(new menus.MainMenuState());
                        }
                        else
                        {
                            substates.PauseSubState.options = false;
                            MusicBeatState.switchState(new PlayState());
                        }
                    }
    
                //what? messy code? what're u talking about?
                //if you think this code is messy, you DONT want to know how it was before
                //edit: code is way better now :cool:
                //ok that didnt work so i had to change it a little bit, but still way better than the first one
                //btw you spelt "wait" instead of "way" in the third comment, you suck bro
                //wtf is this

                versionShit.text = (FlxG.save.data.esp ? "Seleccione una categoria." : "Choose a category.");
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
        gameplay = new KinderButton(0, 140, "Gameplay", "", function()   {   
            MusicBeatState.switchState(new options.GameplayOptions());
        });

        important = new KinderButton(0, 80, (FlxG.save.data.esp ? "Importante" : "Important"), "", function()   {   
            MusicBeatState.switchState(new options.ImportantOptions());
        });

        appearance = new KinderButton(0, 200, (FlxG.save.data.esp ? "Apariencia" : "Appearance"), "", function()   {   
            MusicBeatState.switchState(new options.AppearanceOptions());
        });

        misc = new KinderButton(0, 260, (FlxG.save.data.esp ? "Otros" : "Misc"), "", function()   {   
            MusicBeatState.switchState(new options.MiscOptions());
        });

        buttons.add(gameplay);
        buttons.add(important);
        buttons.add(appearance);
        buttons.add(misc);

        for (i in buttons)
            i.screenCenter(X);
    }
}
