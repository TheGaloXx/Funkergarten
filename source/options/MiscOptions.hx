package options;

import Objects.KinderButton;

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

        fps = new KinderButton(207 - 50, 80, 'FPS: ${Language.get('MiscOptions', 'show_fps_${KadeEngineData.settings.data.fps}')}', Language.get('MiscOptions', 'show_fps_desc'), function()
        {
            KadeEngineData.settings.data.fps = !KadeEngineData.settings.data.fps;
            (cast (openfl.Lib.current.getChildAt(0), Main)).toggleFPS(KadeEngineData.settings.data.fps);
            fps.texto = 'FPS: ${Language.get('MiscOptions', 'show_fps_${KadeEngineData.settings.data.fps}')}';
        });

        snap = new KinderButton(407 - 50, 80, '${Language.get('MiscOptions', 'snap_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.snap}')}', Language.get('MiscOptions', 'snap_desc'), function()
        {
            KadeEngineData.settings.data.snap = !KadeEngineData.settings.data.snap; 
            snap.texto = '${Language.get('MiscOptions', 'snap_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.snap}')}';
        });

        botplay = new KinderButton(207 - 50, 160, 'Botplay: ${Language.get('Global', 'option_${KadeEngineData.botplay}')}', Language.get('MiscOptions', 'botplay_desc'), function()
        {
            KadeEngineData.botplay = !KadeEngineData.botplay; 
            botplay.texto = 'Botplay: ${Language.get('Global', 'option_${KadeEngineData.botplay}')}';
        });

        fullscreen = new KinderButton(407 - 50, 160, '${Language.get('MiscOptions', 'fullscreen_title_${KadeEngineData.settings.data.fullscreen}')}', Language.get('MiscOptions', 'fullscreen_desc'), function()
        {
            KadeEngineData.settings.data.fullscreen = !KadeEngineData.settings.data.fullscreen; 
            flixel.FlxG.fullscreen = KadeEngineData.settings.data.fullscreen;
            fullscreen.texto = '${Language.get('MiscOptions', 'fullscreen_title_${KadeEngineData.settings.data.fullscreen}')}';
        });

        lockSong = new KinderButton(0, 240, '${Language.get('MiscOptions', 'lock_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.lockSong}')}', Language.get('MiscOptions', 'lock_desc'), function()
        {
            KadeEngineData.settings.data.lockSong = !KadeEngineData.settings.data.lockSong; 
            lockSong.texto = '${Language.get('MiscOptions', 'lock_title')} ${Language.get('Global', 'option_${KadeEngineData.settings.data.lockSong}')}';
        });
        lockSong.screenCenter(X);

        buttons.add(fps);
        buttons.add(snap);
        buttons.add(botplay);
        buttons.add(fullscreen);
        //buttons.add(lockSong);
    }
}
