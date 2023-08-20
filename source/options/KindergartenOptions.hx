package options;

import objects.Objects.KinderButton;

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
		add(new objects.SoundSetting(true));
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
                    funkin.MusicBeatState.switchState(new states.MainMenuState());
                else
                {
                    substates.PauseSubState.options = false;
                    funkin.MusicBeatState.switchState(new states.PlayState());
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
            funkin.MusicBeatState.switchState(new options.GameplayOptions(new options.KindergartenOptions(null)));
        }));
        buttons.add(new KinderButton(0, 80, Language.get('KindergartenOptions', 'important'), "", function()   {   
            funkin.MusicBeatState.switchState(new options.ImportantOptions(new options.KindergartenOptions(null)));
        }));
        buttons.add(new KinderButton(0, 200, Language.get('KindergartenOptions', 'appearance'), "", function()   {   
            funkin.MusicBeatState.switchState(new options.AppearanceOptions(new options.KindergartenOptions(null)));
        }));
        buttons.add(new KinderButton(0, 260, Language.get('KindergartenOptions', 'misc'), "", function()   {   
            funkin.MusicBeatState.switchState(new options.MiscOptions(new options.KindergartenOptions(null)));
        }));

        for (i in buttons)
            i.screenCenter(X);
    }
}
