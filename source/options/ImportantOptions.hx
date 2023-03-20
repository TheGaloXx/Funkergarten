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

class ImportantOptions extends MusicBeatState
{
    public static var instance:ImportantOptions;

	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

    var buttons:FlxTypedGroup<KinderButton>;
    var controlsButton:KinderButton;
    var fpsCap:KinderButton;
    var flashing:KinderButton;
    var language:KinderButton;
    var mechanic:KinderButton;

    public var acceptInput:Bool = true; //FOR KEYBINDS

	override function create()
	{
        instance = this;

		FlxG.mouse.visible = true;

		//(cast (Lib.current.getChildAt(0), Main)).setFPSCap(120); bug de bajon de fps

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/menuDesat"));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		add(menuBG);

        var paper:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/page'));
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

        if (acceptInput) //KEYBINDS
        {
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
    
                    if      (controlsButton.selected)   versionShit.text = controlsButton.description;
                    else if (fpsCap.selected)           versionShit.text = fpsCap.description;
                    else if (flashing.selected)         versionShit.text = flashing.description; 
                    else if (language.selected)         versionShit.text = language.description;
                    else if (mechanic.selected)         versionShit.text = mechanic.description;
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
        }

		FlxG.save.flush();
	}



    function addButtons():Void
    {
        buttons = new FlxTypedGroup<KinderButton>();
        add(buttons);



        //still pretty messy but at least way better than the old one :coolface:
        controlsButton = new KinderButton(207 - 50, 80, (FlxG.save.data.esp ? "Controles" : "Controls"), (FlxG.save.data.esp ? "Ajusta tus controles." : "Choose your controls."), function()   {   
            openSubState(new menus.KeyBindMenu());
        });


        fpsCap = new KinderButton(407 - 50, 80, (FlxG.save.data.esp ? "Limite de FPS: " : "Frame rate: ") + FlxG.save.data.fpsCap, (FlxG.save.data.esp ? "Ajusta el limite de FPS.  (NOTA: SI SE AJUSTA A 60 FPS, LOS MENUS PUEDEN SER LENTOS, EL GAMEPLAY ESTA BIEN)" : "Change the FPS limit.    (NOTE: IF YOU CHOOSE 60 FPS, THE MENUS COULD BE SLOW, BUT THE GAMEPLAY IS OK)"), function()    {
            FlxG.save.data.fpsCap += 60;
            if (FlxG.save.data.fpsCap > 240)
                FlxG.save.data.fpsCap = 60;

            fpsCap.texto = (FlxG.save.data.esp ? "Limite de FPS: " : "Frame rate: ") + FlxG.save.data.fpsCap;

            #if !web
		    FlxG.drawFramerate = FlxG.updateFramerate = FlxG.save.data.fpsCap;
		    #end
        });


        flashing = new KinderButton(207 - 50, 160, (FlxG.save.data.esp ? "Luces fuertes: " : "Flashing lights: ") + (FlxG.save.data.esp ? (FlxG.save.data.flashing ? 'Si' : 'No') : (FlxG.save.data.flashing ? 'On' : 'Off')), (FlxG.save.data.esp ? "Activa las luces parpadeantes que puedan causar daños a la vista o epilepsia." : "Toggle flashing lights that can cause epileptic seizures and strain."), function()    {
            FlxG.save.data.flashing = !FlxG.save.data.flashing; 
            flashing.texto = (FlxG.save.data.esp ? "Luces fuertes: " : "Flashing lights: ") + (FlxG.save.data.esp ? (FlxG.save.data.flashing ? 'Si' : 'No') : (FlxG.save.data.flashing ? 'On' : 'Off'));
        });


        language = new KinderButton(407 - 50, 160, (FlxG.save.data.esp ? "English" : "Espanol"), (FlxG.save.data.esp ? "Cambia el idioma de espanol a ingles o viceversa." : "Changes the language from english to spanish or viceversa."), function()    {
            FlxG.save.data.esp = !FlxG.save.data.esp; 
            language.texto = (FlxG.save.data.esp ? "English" : "Espanol");
            FlxG.resetState();
        });
        

        mechanic = new KinderButton(0, 240, (FlxG.save.data.esp ? "Mecanicas: " : "Mechanics: ") + (FlxG.save.data.esp ? (FlxG.save.data.mechanics ? 'Si' : 'No') : (FlxG.save.data.mechanics ? 'On' : 'Off')), (FlxG.save.data.esp ? "Activa o desactiva las mecanicas que aumentan la dificultad." : "Toggle the mechanics that make the game harder."), function() {
            FlxG.save.data.mechanics = !FlxG.save.data.mechanics; 
            mechanic.texto = (FlxG.save.data.esp ? "Mecanicas: " : "Mechanics: ") + (FlxG.save.data.esp ? (FlxG.save.data.mechanics ? 'Si' : 'No') : (FlxG.save.data.mechanics ? 'On' : 'Off'));
        });
        mechanic.screenCenter(X);


        /*add(controlsButton);
        add(fpsCap);
        add(flashing);
        add(language);
        add(mechanic);*/

        buttons.add(controlsButton);
        buttons.add(fpsCap);
        buttons.add(flashing);
        buttons.add(language);
        buttons.add(mechanic);
    }
}
