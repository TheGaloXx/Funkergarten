package options;

import states.PlayState;
import states.MainMenuState;
import objects.SoundSetting;
import substates.PauseSubState;
import funkin.MusicBeatState;

class KindergartenOptions extends OptionsMenuBase
{
    public static var instance:KindergartenOptions;

	override function create()
	{
        instance = this;

		CoolUtil.title('Options Menu');
		CoolUtil.presence(null, 'In options menu', false, 0, null);

		super.create();

		add(new SoundSetting(true));
	}

	override function update(elapsed:Float)
	{
        if (!canDoSomething)
            return;

        if (controls.BACK)
        {
            trace("backes in a epic way");
            canDoSomething = false;
                    
            if (!PauseSubState.options)
                MusicBeatState.switchState(new MainMenuState());
            else
            {
                PauseSubState.options = false;
                MusicBeatState.switchState(new PlayState());
            }
        }

		super.update(elapsed);
	}

    override private function addButtons():Void
    {
        addButton("Gameplay").finishThing = function()
            MusicBeatState.switchState(new GameplayOptions(new KindergartenOptions(null)));

        addButton(Language.get('KindergartenOptions', 'appearance')).finishThing = function()
            MusicBeatState.switchState(new AppearanceOptions(new KindergartenOptions(null)));

        addButton(Language.get('KindergartenOptions', 'other')).finishThing = function()
            MusicBeatState.switchState(new MiscOptions(new KindergartenOptions(null)));
    }
}