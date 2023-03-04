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

class GameplayOptions extends MusicBeatState
{
	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

    var buttons:FlxTypedGroup<KinderButton>;
    var downscroll:KinderButton;
    var middlescroll:KinderButton;
    var practice:KinderButton;
    var customize:KinderButton;

	override function create()
	{
		FlxG.mouse.visible = true;

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
                                
                        MusicBeatState.switchState(new KindergartenOptions());
                    }
    
                //what? messy code? what're u talking about?
                //if you think this code is messy, you DONT want to know how it was before
                //edit: code is way better now :cool:
                //ok that didnt work so i had to change it a little bit, but still way better than the first one
                //btw you spelt "wait" instead of "way" in the third comment, you suck bro
                //wtf is this bro

                if      (downscroll.selected)       versionShit.text = downscroll.description;
                else if (middlescroll.selected)     versionShit.text = middlescroll.description;
                else if (practice.selected)         versionShit.text = practice.description; 
                else if (customize.selected)        versionShit.text = customize.description;
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
        downscroll = new KinderButton(207 - 50, 80, (FlxG.save.data.downscroll ? "Downscroll" : "Upscroll"), (FlxG.save.data.esp ? "Cambia si las notas suben o bajan." : "Change if the notes go up or down."), function()   {   
            openSubState(new menus.KeyBindMenu());
        });


        middlescroll = new KinderButton(407 - 50, 80, "Middlescroll: " + (FlxG.save.data.esp ? (FlxG.save.data.middlescroll ? 'Si' : 'No') : (FlxG.save.data.middlescroll ? 'On' : 'Off')), (FlxG.save.data.esp ? "Cambia la posicion de las notas al medio." : "Change the layout of the strumline to the center."), function()    {
            FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll; 
            middlescroll.texto = "Middlescroll: " + (FlxG.save.data.esp ? (FlxG.save.data.middlescroll ? 'Si' : 'No') : (FlxG.save.data.middlescroll ? 'On' : 'Off'));
        });


        practice = new KinderButton(207 - 50, 160, (FlxG.save.data.esp ? "Modo practica: " : "Practice mode: ") + (FlxG.save.data.esp ? (FlxG.save.data.practice ? 'Si' : 'No') : (FlxG.save.data.practice ? 'On' : 'Off')), (FlxG.save.data.esp ? "Si se activa no puedes morir." : "If enabled, you can't die... cheater."), function()    {
            FlxG.save.data.practice = !FlxG.save.data.practice; 
            practice.texto = (FlxG.save.data.esp ? "Modo practica: " : "Practice mode: ") + (FlxG.save.data.esp ? (FlxG.save.data.practice ? 'Si' : 'No') : (FlxG.save.data.practice ? 'On' : 'Off'));
        });


        customize = new KinderButton(407 - 50, 160, (FlxG.save.data.esp ? "Personalizar gameplay" : "Customize gameplay"), (FlxG.save.data.esp ? "Mueve los sprite de combo a tu preferencia." : "Move Gameplay Modules around to your preference."), function()    {
            canDoSomething = false; 
            MusicBeatState.switchState(new options.GameplayCustomizeState());
        });

        buttons.add(downscroll);
        buttons.add(middlescroll);
        buttons.add(practice);
        buttons.add(customize);
        buttons.add(customize);
    }
}
