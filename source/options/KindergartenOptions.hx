package options;

import Objects.KinderButton;

class KindergartenOptions extends OptionsMenuBase
{
    public static var instance:KindergartenOptions;
    
	override function create()
	{
        instance = this;

		CoolUtil.title('Options Menu');
		CoolUtil.presence(null, 'In options menu', false, 0, null);

		super.create();

        addButtons();
		add(new SoundSetting(true));
	}

	override function update(elapsed:Float)
	{
        if (canDoSomething)
        {
            if (controls.BACK)
            {
                trace("backes in a epic way");
                canDoSomething = false;
                                
                if (!substates.PauseSubState.options)
                    MusicBeatState.switchState(new menus.MainMenuState());
                else
                {
                    substates.PauseSubState.options = false;
                    MusicBeatState.switchState(new PlayState());
                }
            }

            versionShit.text = Language.get('KindergartenOptions', 'idle_text');
        }

		super.update(elapsed);

        versionShit.text = Language.get('KindergartenOptions', 'idle_text');
	}



    function addButtons():Void
    {
        buttons.add(new KinderButton(0, 140, "Gameplay", "", function()   {   
            MusicBeatState.switchState(new options.GameplayOptions(new options.KindergartenOptions(null)));
        }));
        buttons.add(new KinderButton(0, 80, Language.get('KindergartenOptions', 'important'), "", function()   {   
            MusicBeatState.switchState(new options.ImportantOptions(new options.KindergartenOptions(null)));
        }));
        buttons.add(new KinderButton(0, 200, Language.get('KindergartenOptions', 'appearance'), "", function()   {   
            MusicBeatState.switchState(new options.AppearanceOptions(new options.KindergartenOptions(null)));
        }));
        buttons.add(new KinderButton(0, 260, Language.get('KindergartenOptions', 'misc'), "", function()   {   
            MusicBeatState.switchState(new options.MiscOptions(new options.KindergartenOptions(null)));
        }));

        for (i in buttons)
            i.screenCenter(X);
    }
}
