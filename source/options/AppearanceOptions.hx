package options;

import Objects.KinderButton;

// TODO: make language getting more typo proof and dynamic (example use the Type/Class name shit) - lo pongo aqui porque es el primero que hice xd
class AppearanceOptions extends OptionsMenuBase
{
    var antialiasing:KinderButton;
	var bf = new flixel.FlxSprite();
	var a = new flixel.text.FlxText();

	override function create()
	{
        super.create();

        addButtons();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (canDoSomething)
            bf.visible = a.visible = antialiasing.selected;
	}

    function addButtons():Void
    {
        var shaders:KinderButton = null;
        var camMove:KinderButton = null;
        var distractions:KinderButton = null;
        var accuracyDisplay:KinderButton = null;
        var songPosition:KinderButton = null;

        antialiasing = new KinderButton(207 - 50, 80, 'Antialiasing: ${Language.get('Global', 'option_${KadeEngineData.settings.data.antialiasing}')}', Language.get('AppearanceOptions', 'antialiasing_desc'), function()
        {
            KadeEngineData.settings.data.antialiasing = !KadeEngineData.settings.data.antialiasing;
            var antialias:Bool = KadeEngineData.settings.data.antialiasing;
            flixel.FlxSprite.defaultAntialiasing = antialias;
            bf.antialiasing = a.antialiasing = antialias;
            a.text = 'Antialiasing: ${Language.get('Global', 'option_${antialias}')}'.toLowerCase();
            antialiasing.texto = 'Antialiasing: ${Language.get('Global', 'option_${antialias}')}';
        });

        shaders = new KinderButton(407 - 50, 80, 'Shaders: ${Language.get('Global', 'option_${KadeEngineData.settings.data.shaders}')}', Language.get('AppearanceOptions', 'shaders_desc'), function()
        {
            KadeEngineData.settings.data.shaders = !KadeEngineData.settings.data.shaders;
            shaders.texto = 'Shaders: ${Language.get('Global', 'option_${KadeEngineData.settings.data.shaders}')}';
        });

        camMove = new KinderButton(207 - 50, 160, '${Language.get('AppearanceOptions', 'cam_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.camMove}')}', Language.get('AppearanceOptions', 'cam_desc'), function()
        {
            KadeEngineData.settings.data.camMove = !KadeEngineData.settings.data.camMove;
            camMove.texto = '${Language.get('AppearanceOptions', 'cam_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.camMove}')}';
        });

        distractions = new KinderButton(407 - 50, 160, '${Language.get('AppearanceOptions', 'disc_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.distractions}')}', Language.get('AppearanceOptions', 'disc_desc'), function()
        {
            KadeEngineData.settings.data.distractions = !KadeEngineData.settings.data.distractions;
            distractions.texto = '${Language.get('AppearanceOptions', 'disc_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.distractions}')}';
        });

        accuracyDisplay = new KinderButton(207 - 50, 240, '${Language.get('AppearanceOptions', 'acc_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.accuracyDisplay}')}', Language.get('AppearanceOptions', 'acc_desc'), function()
        {
            KadeEngineData.settings.data.accuracyDisplay = !KadeEngineData.settings.data.accuracyDisplay;
            accuracyDisplay.texto = '${Language.get('AppearanceOptions', 'acc_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.accuracyDisplay}')}';
        });

        songPosition = new KinderButton(407 - 50, 240, '${Language.get('AppearanceOptions', 'songpos_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.songPosition}')}', Language.get('AppearanceOptions', 'songpos_desc'), function()
        {
            KadeEngineData.settings.data.songPosition = !KadeEngineData.settings.data.songPosition;
            songPosition.texto = '${Language.get('AppearanceOptions', 'songpos_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.songPosition}')}';
        });

        buttons.add(antialiasing);
        buttons.add(shaders);
        buttons.add(camMove);
        buttons.add(distractions);
        buttons.add(accuracyDisplay);
        buttons.add(songPosition);
    }

    private function addAntialiasingShit():Void
    {
        bf.frames = Paths.getSparrowAtlas('characters/bf', 'shared');
		bf.animation.addByPrefix('idle', 'BF idle dance', 24, true);
		bf.scale.set(0.4, 0.4);
		bf.updateHitbox();
		bf.setPosition(flixel.FlxG.width - bf.width, flixel.FlxG.height - bf.height);
		bf.animation.play('idle', true);
		bf.visible = false;
		add(bf);

		a.alignment = CENTER;
		a.size = 25;
		a.x = 1046;
		a.y = 685.5;
		a.visible = false;
        a.text = (KadeEngineData.settings.data.antialiasing ? "antialiasing on" : "antialiasing off");
		add(a);
    }
}