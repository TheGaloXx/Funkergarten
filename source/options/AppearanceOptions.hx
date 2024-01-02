package options;

import flixel.FlxSprite;

// TODO: make language getting more typo proof and dynamic (example use the Type/Class name shit) - lo pongo aqui porque es el primero que hice xd
class AppearanceOptions extends OptionsMenuBase
{
    override private function addButtons():Void
    {
        var antialiasing = addButton('Antialiasing: ${Language.get('Global', 'option_${data().antialiasing}')}');
        antialiasing.finishThing = function()
        {
            data().antialiasing = !data().antialiasing;
            antialiasing.texto = 'Antialiasing: ${Language.get('Global', 'option_${data().antialiasing}')}';
            FlxSprite.defaultAntialiasing = data().antialiasing; // how did i forget this
        }

        var flashing = addButton('${Language.get('AppearanceOptions', 'flashing_title')} ${Language.get('Global', 'option_${data().flashing}')}');
        flashing.finishThing = function()
        {
            data().flashing = !data().flashing;
            flashing.texto = '${Language.get('AppearanceOptions', 'flashing_title')} ${Language.get('Global', 'option_${data().flashing}')}';
        };

        var shaders = addButton('Shaders: ${Language.get('Global', 'option_${data().shaders}')}');
        shaders.finishThing = function()
        {
            data().shaders = !data().shaders;
            shaders.texto = 'Shaders: ${Language.get('Global', 'option_${data().shaders}')}';
        }

        var camMove = addButton('${Language.get('AppearanceOptions', 'cam_title')} ${Language.get('Global', 'option_${data().camMove}')}');
        camMove.finishThing = function()
        {
            data().camMove = !data().camMove;
            camMove.texto = '${Language.get('AppearanceOptions', 'cam_title')} ${Language.get('Global', 'option_${data().camMove}')}';
        }

        var lowQuality = addButton('${Language.get('AppearanceOptions', 'quality_title')} ${Language.get('Global', 'option_${data().lowQuality}')}');
        lowQuality.finishThing = function()
        {
            data().lowQuality = !data().lowQuality;
            lowQuality.texto = '${Language.get('AppearanceOptions', 'quality_title')} ${Language.get('Global', 'option_${data().lowQuality}')}';
        };

        var zooms = addButton('${Language.get('AppearanceOptions', 'zooms_title')} ${Language.get('Global', 'option_${data().zooms}')}');
        zooms.finishThing = function()
        {
            data().zooms = !data().zooms;
            zooms.texto = '${Language.get('AppearanceOptions', 'zooms_title')} ${Language.get('Global', 'option_${data().zooms}')}';
        };
    }
}