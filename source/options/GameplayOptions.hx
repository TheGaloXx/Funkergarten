package options;

import states.KeyBindMenu;
import funkin.MusicBeatState;

class GameplayOptions extends OptionsMenuBase
{
    public static var instance:GameplayOptions;
    public var acceptInput:Bool = true; //FOR KEYBINDS

    override function create()
    {
        instance = this;
    
        super.create();
    }

    override private function addButtons():Void
    {
        addButton(Language.get('GameplayOptions', 'controls_title')).finishThing = function()
        {
            openSubState(new KeyBindMenu());
        }

        var mechanic = addButton('${Language.get('GameplayOptions', 'mechanics_title')} ${Language.get('Global', 'option_${data().mechanics}')}');
        mechanic.finishThing = function()
        {
            data().mechanics = !data().mechanics;
            mechanic.texto = '${Language.get('GameplayOptions', 'mechanics_title')} ${Language.get('Global', 'option_${data().mechanics}')}';
        };

        //still pretty messy but at least way better than the old one :coolface:
        var downscroll = addButton((data().downscroll ? 'Downscroll' : 'Upscroll'));
        downscroll.finishThing = function()
        {
            data().downscroll = !data().downscroll;
            downscroll.texto = (data().downscroll ? 'Downscroll' : 'Upscroll');
        };

        var middlescroll = addButton('Middlescroll: ${Language.get('Global', 'option_${data().middlescroll}')}');
        middlescroll.finishThing = function()
        {
            data().middlescroll = !data().middlescroll;
            middlescroll.texto = 'Middlescroll: ${Language.get('Global', 'option_${data().middlescroll}')}';
        };

        var customize = addButton(Language.get('GameplayOptions', 'customize_title'));
        customize.finishThing = function()
        {
            canDoSomething = false; 
            MusicBeatState.switchState(new options.GameplayCustomizeState());
        };

        var ghosttap = addButton('Ghost tapping: ${Language.get('Global', 'option_${data().ghostTap}')}');
        ghosttap.finishThing = function()
        {
            data().ghostTap = !data().ghostTap;
            ghosttap.texto = 'Ghost tapping: ${Language.get('Global', 'option_${data().ghostTap}')}';
        };
    }
}
