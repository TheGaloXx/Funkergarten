package options;

import objects.Objects.KinderButton;

class MiscOptions extends OptionsMenuBase
{
	override function create()
	{
		super.create();
        addButtons();
	}

    function addButtons():Void
    {
        var fps:KinderButton = null;
        var snap:KinderButton = null;
        var botplay:KinderButton = null;
        var fullscreen:KinderButton = null;
        var lockSong:KinderButton = null;

        fps = new KinderButton(207 - 50, 80, 'FPS: ${Language.get('MiscOptions', 'show_fps_${data.KadeEngineData.settings.data.fps}')}', Language.get('MiscOptions', 'show_fps_desc'), function()
        {
            data.KadeEngineData.settings.data.fps = !data.KadeEngineData.settings.data.fps;
            (cast (openfl.Lib.current.getChildAt(0), Main)).toggleFPS(data.KadeEngineData.settings.data.fps);
            fps.texto = 'FPS: ${Language.get('MiscOptions', 'show_fps_${data.KadeEngineData.settings.data.fps}')}';
        });

        snap = new KinderButton(407 - 50, 80, '${Language.get('MiscOptions', 'snap_title')} ${Language.get('Global', 'option_${data.KadeEngineData.settings.data.snap}')}', Language.get('MiscOptions', 'snap_desc'), function()
        {
            data.KadeEngineData.settings.data.snap = !data.KadeEngineData.settings.data.snap; 
            snap.texto = '${Language.get('MiscOptions', 'snap_title')} ${Language.get('Global', 'option_${data.KadeEngineData.settings.data.snap}')}';
        });

        botplay = new KinderButton(207 - 50, 160, 'Botplay: ${Language.get('Global', 'option_${data.KadeEngineData.botplay}')}', Language.get('MiscOptions', 'botplay_desc'), function()
        {
            data.KadeEngineData.botplay = !data.KadeEngineData.botplay; 
            botplay.texto = 'Botplay: ${Language.get('Global', 'option_${data.KadeEngineData.botplay}')}';
        });

        fullscreen = new KinderButton(407 - 50, 160, '${Language.get('MiscOptions', 'fullscreen_title_${data.KadeEngineData.settings.data.fullscreen}')}', Language.get('MiscOptions', 'fullscreen_desc'), function()
        {
            data.KadeEngineData.settings.data.fullscreen = !data.KadeEngineData.settings.data.fullscreen; 
            flixel.FlxG.fullscreen = data.KadeEngineData.settings.data.fullscreen;
            fullscreen.texto = '${Language.get('MiscOptions', 'fullscreen_title_${data.KadeEngineData.settings.data.fullscreen}')}';
        });

        lockSong = new KinderButton(0, 240, '${Language.get('MiscOptions', 'lock_title')} ${Language.get('Global', 'option_${data.KadeEngineData.settings.data.lockSong}')}', Language.get('MiscOptions', 'lock_desc'), function()
        {
            data.KadeEngineData.settings.data.lockSong = !data.KadeEngineData.settings.data.lockSong; 
            lockSong.texto = '${Language.get('MiscOptions', 'lock_title')} ${Language.get('Global', 'option_${data.KadeEngineData.settings.data.lockSong}')}';
        });
        lockSong.screenCenter(X);

        buttons.add(fps);
        buttons.add(snap);
        buttons.add(botplay);
        buttons.add(fullscreen);
        //buttons.add(lockSong);
    }
}
