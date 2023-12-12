package options;

import input.Controls.ActionType;
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
		CoolUtil.presence(null, Language.get('Discord_Presence', 'options_menu'), false, 0, null);

		super.create();

		add(new SoundSetting(true));
	}

    override function onActionPressed(action:ActionType)
    {
        if (!canDoSomething)
            return;

        if (action == BACK)
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