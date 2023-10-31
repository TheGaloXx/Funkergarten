package options;

import states.LanguageState;
import funkin.MusicBeatState;
import flixel.FlxG;

class MiscOptions extends OptionsMenuBase
{
    override private function addButtons():Void
    {
        addButton(Language.get('Global', 'next_locale')).finishThing = function()
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

        var fullscreen = addButton('${Language.get('MiscOptions', 'fullscreen_title_${data().fullscreen}')}');
        fullscreen.finishThing = function()
        {
            data().fullscreen = !data().fullscreen; 
            FlxG.fullscreen = data().fullscreen;
            fullscreen.texto = '${Language.get('MiscOptions', 'fullscreen_title_${data().fullscreen}')}';
        };

        var fpsCap = addButton('${Language.get('ImportantOptions', 'fps_title')} ' + data().fpsCap);
        fpsCap.finishThing = function()
        {
            data().fpsCap += 60;

            if (data().fpsCap > 240)
                data().fpsCap = 60;

            fpsCap.texto = '${Language.get('ImportantOptions', 'fps_title')} ' + data().fpsCap;

            #if !web
            Main.changeFPS(data().fpsCap);
            #end
        };

        addButton('Colorblind filter').finishThing = function()
        {
            MusicBeatState.switchState(new ColorblindMenu());
        };
    }
}
