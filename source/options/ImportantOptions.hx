package options;

import flixel.FlxG;
import Objects.KinderButton;

class ImportantOptions extends OptionsMenuBase
{
    public static var instance:ImportantOptions;
    public var acceptInput:Bool = true; //FOR KEYBINDS

	override function create()
	{
        instance = this;

        super.create();

        addButtons();
	}

	override function update(elapsed:Float)
	{
        if (acceptInput)
            super.update(elapsed);
	}

    function addButtons():Void
    {
        var fpsCap:KinderButton = null;
        var flashing:KinderButton = null;
        var language:KinderButton = null;
        var mechanic:KinderButton = null;

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
        // alr sanco idk how to do this, just change this to "change language" but translate it to every language
        language = new KinderButton(407 - 50, 160, Language.get('Global', 'next_locale'), Language.get('ImportantOptions', 'lang_desc'), function()    
        {
            /*
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
            */

            MusicBeatState.switchState(new menus.LanguageState(true));
        });

        mechanic = new KinderButton(0, 240, '${Language.get('ImportantOptions', 'mech_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.mechanics}')}', Language.get('ImportantOptions', 'mech_desc'), function() {
            KadeEngineData.settings.data.mechanics = !KadeEngineData.settings.data.mechanics;
            mechanic.texto = '${Language.get('ImportantOptions', 'mech_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.mechanics}')}';
        });
        mechanic.screenCenter(X);

        
        buttons.add(new KinderButton(207 - 50, 80, Language.get('ImportantOptions', 'controls_title'), Language.get('ImportantOptions', 'controls_desc'), function()
            {   
                openSubState(new menus.KeyBindMenu());
            }));
        buttons.add(fpsCap);
        buttons.add(flashing);
        buttons.add(language);
        buttons.add(mechanic);
    }
}
