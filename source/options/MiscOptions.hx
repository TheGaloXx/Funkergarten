package options;

import states.LanguageState;
import funkin.MusicBeatState;
import flixel.FlxG;

class MiscOptions extends OptionsMenuBase
{
    override private function addButtons():Void
    {
        addButton(Language.get('MiscOptions', 'language')).finishThing = function()
        {
            MusicBeatState.switchState(new LanguageState(true));
        };

        var fps = addButton('FPS: ${Language.get('MiscOptions', 'show_fps_${data().fps}')}');
        fps.finishThing = function()
        {
            data().fps = !data().fps;

            (cast (openfl.Lib.current.getChildAt(0), Main)).toggleFPS(data().fps);
    
            fps.texto = 'FPS: ${Language.get('MiscOptions', 'show_fps_${data().fps}')}';
        }

        var fullscreen = addButton('${Language.get('MiscOptions', 'fullscreen_title_${FlxG.fullscreen}')}');
        fullscreen.finishThing = function()
        {
            FlxG.fullscreen = !FlxG.fullscreen;
            data().fullscreen = FlxG.fullscreen;
            fullscreen.texto = '${Language.get('MiscOptions', 'fullscreen_title_${FlxG.fullscreen}')}';
        };

        var fpsCap = addButton('${Language.get('MiscOptions', 'fps_cap')} ' + data().fpsCap);
        fpsCap.finishThing = function()
        {
            data().fpsCap += 60;

            if (data().fpsCap > 240)
                data().fpsCap = 60;

            fpsCap.texto = '${Language.get('MiscOptions', 'fps_cap')} ' + data().fpsCap;

            #if !web
            Main.changeFPS(data().fpsCap);
            #end
        };

        addButton(Language.get('MiscOptions', 'colorblind_title')).finishThing = function()
        {
            MusicBeatState.switchState(new ColorblindMenu());
        };
    }
}
