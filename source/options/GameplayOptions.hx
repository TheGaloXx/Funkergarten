package options;

import objects.Objects.KinderButton;

class GameplayOptions extends OptionsMenuBase
{
	override function create()
	{
        super.create();

        addButtons();
	}

    function addButtons():Void
    {
        var downscroll:KinderButton = null;
        var middlescroll:KinderButton = null;
        var practice:KinderButton = null;
        var customize:KinderButton = null;
        var ghosttap:KinderButton = null;

        //still pretty messy but at least way better than the old one :coolface:
        downscroll = new KinderButton(207 - 50, 80, Language.get('GameplayOptions', 'downscroll_${data.KadeEngineData.settings.data.downscroll}'), Language.get('GameplayOptions', 'downscroll_desc'), function()
        {   
            data.KadeEngineData.settings.data.downscroll = !data.KadeEngineData.settings.data.downscroll;
            downscroll.texto = Language.get('GameplayOptions', 'downscroll_${data.KadeEngineData.settings.data.downscroll}');
        });

        middlescroll = new KinderButton(407 - 50, 80, 'Middlescroll: ${Language.get('Global', 'option_${data.KadeEngineData.settings.data.middlescroll}')}', Language.get('GameplayOptions', 'middlescroll_desc'), function()
        {
            data.KadeEngineData.settings.data.middlescroll = !data.KadeEngineData.settings.data.middlescroll;
            middlescroll.texto = 'Middlescroll: ${Language.get('Global', 'option_${data.KadeEngineData.settings.data.middlescroll}')}';
        });

        practice = new KinderButton(207 - 50, 160, '${Language.get('GameplayOptions', 'practice_title')} ${Language.get('Global', 'option_${data.KadeEngineData.practice}')}', Language.get('GameplayOptions', 'practice_desc'), function()
        {
            data.KadeEngineData.practice = !data.KadeEngineData.practice; 
            practice.texto = '${Language.get('GameplayOptions', 'practice_title')} ${Language.get('Global', 'option_${data.KadeEngineData.practice}')}';
        });
        '\'';

        customize = new KinderButton(407 - 50, 160, Language.get('GameplayOptions', 'customize_title'), Language.get('GameplayOptions', 'customize_desc'), function()
        {
            canDoSomething = false; 
            funkin.MusicBeatState.switchState(new options.GameplayCustomizeState());
        });

        ghosttap = new KinderButton(0, 240, (data.KadeEngineData.settings.data.ghostTap ? '' : 'No ') + "Ghost Tapping", Language.get('GameplayOptions', 'ghosttap_desc'), function()
        {
            data.KadeEngineData.settings.data.ghostTap = !data.KadeEngineData.settings.data.ghostTap;
            ghosttap.texto = (data.KadeEngineData.settings.data.ghostTap) ? "Ghost Tapping" : "No Ghost Tapping";
        });
        ghosttap.screenCenter(X);
    
        buttons.add(downscroll);
        buttons.add(middlescroll);
        buttons.add(practice);
        buttons.add(customize);
        buttons.add(ghosttap);
    }
}
