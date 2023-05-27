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
                    else                                versionShit.text = Language.get('Global', 'options_idle');
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

		KadeEngineData.flush(false);
	}



    function addButtons():Void
    {
        buttons = new FlxTypedGroup<KinderButton>();
        add(buttons);

        //still pretty messy but at least way better than the old one :coolface:
        controlsButton = new KinderButton(207 - 50, 80, Language.get('ImportantOptions', 'controls_title'), Language.get('ImportantOptions', 'controls_desc'), function()
        {   
            openSubState(new menus.KeyBindMenu());
        });

        fpsCap = new KinderButton(407 - 50, 80, '${Language.get('ImportantOptions', 'fps_title')} ' + KadeEngineData.settings.data.fpsCap, Language.get('ImportantOptions', 'fps_desc'), function()
        {
            KadeEngineData.settings.data.fpsCap += 60;
            if (KadeEngineData.settings.data.fpsCap > 240)
                KadeEngineData.settings.data.fpsCap = 60;

            fpsCap.texto = '${Language.get('ImportantOptions', 'fps_title')} ' + KadeEngineData.settings.data.fpsCap;

            #if !web
            Main.changeFPS(KadeEngineData.settings.data.fpsCap);
            #end
        });

        flashing = new KinderButton(207 - 50, 160, '${Language.get('ImportantOptions', 'flashing_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.flashing}')}', Language.get('ImportantOptions', 'flashing_desc'), function()
        {
            KadeEngineData.settings.data.flashing = !KadeEngineData.settings.data.flashing;
            flashing.texto = '${Language.get('ImportantOptions', 'flashing_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.flashing}')}';
        });

        // only changed this one cuz i needed it
        language = new KinderButton(407 - 50, 160, Language.get('Global', 'next_locale'), Language.get('ImportantOptions', 'lang_desc'), function()    
        {
            var curLocale:String = KadeEngineData.settings.data.language;

            switch(curLocale)
            {
                case "en_US":
                    KadeEngineData.settings.data.language = "es_ES";
                case "es_ES":
                    KadeEngineData.settings.data.language = "en_US";
            }

            language.texto = Language.get('Global', 'next_locale');
            Language.populate();
            FlxG.resetState();
        });
        

        mechanic = new KinderButton(0, 240, '${Language.get('ImportantOptions', 'mech_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.mechanics}')}', Language.get('ImportantOptions', 'mech_desc'), function() {
            KadeEngineData.settings.data.mechanics = !KadeEngineData.settings.data.mechanics;
            mechanic.texto = '${Language.get('ImportantOptions', 'mech_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.mechanics}')}';
        });
        mechanic.screenCenter(X);

        buttons.add(controlsButton);
        buttons.add(fpsCap);
        buttons.add(flashing);
        buttons.add(language);
        buttons.add(mechanic);
    }
}
