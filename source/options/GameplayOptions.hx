package options;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import Objects.KinderButton;

class GameplayOptions extends MusicBeatState
{
	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

    var buttons:FlxTypedGroup<KinderButton>;
    var downscroll:KinderButton;
    var middlescroll:KinderButton;
    var practice:KinderButton;
    var customize:KinderButton;
    var ghosttap:KinderButton;

	override function create()
	{
		var time = Date.now().getHours();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/paper', 'preload'));
		bg.active = false;
		if (time > 19 || time < 8)
			bg.alpha = 0.7;
		add(bg);

        var paper:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/page', 'preload'));
        paper.screenCenter();
        add(paper);

		versionShit = new FlxText(5, FlxG.height + 40, 0, "", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.BLACK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		versionShit.borderSize = 1.25;
		
		blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 1500)), Std.int(versionShit.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.8;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});

        addButtons();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (canDoSomething)
            {
                if (controls.BACK)
                    {
                        trace("backes in a epic way");
                        canDoSomething = false;
                                
                        MusicBeatState.switchState(new KindergartenOptions());
                    }
    
                //what? messy code? what're u talking about?
                //if you think this code is messy, you DONT want to know how it was before
                //edit: code is way better now :cool:
                //ok that didnt work so i had to change it a little bit, but still way better than the first one
                //btw you spelt "wait" instead of "way" in the third comment, you suck bro
                //wtf is this bro

                if      (downscroll.selected)       versionShit.text = downscroll.description;
                else if (middlescroll.selected)     versionShit.text = middlescroll.description;
                else if (practice.selected)         versionShit.text = practice.description; 
                else if (customize.selected)        versionShit.text = customize.description;
                else                                versionShit.text = Language.get('Global', 'options_idle');
            }
            else
            {
                versionShit.text = "";

                buttons.forEach(function(button:KinderButton)
                    {
                        button.active = false;
                    });
            }

            KadeEngineData.flush(false);
	}



    function addButtons():Void
    {
        buttons = new FlxTypedGroup<KinderButton>();
        add(buttons);

        //still pretty messy but at least way better than the old one :coolface:
        downscroll = new KinderButton(207 - 50, 80, Language.get('GameplayOptions', 'downscroll_${KadeEngineData.settings.data.downscroll}'), Language.get('GameplayOptions', 'downscroll_desc'), function()
        {   
            KadeEngineData.settings.data.downscroll = !KadeEngineData.settings.data.downscroll;
            downscroll.texto = Language.get('GameplayOptions', 'downscroll_${KadeEngineData.settings.data.downscroll}');
        });

        middlescroll = new KinderButton(407 - 50, 80, 'Middlescroll: ${Language.get('Global', 'option_${KadeEngineData.settings.data.middlescroll}')}', Language.get('GameplayOptions', 'middlescroll_desc'), function()
        {
            KadeEngineData.settings.data.middlescroll = !KadeEngineData.settings.data.middlescroll;
            middlescroll.texto = 'Middlescroll: ${Language.get('Global', 'option_${KadeEngineData.settings.data.middlescroll}')}';
        });

        practice = new KinderButton(207 - 50, 160, '${Language.get('GameplayOptions', 'practice_title')} ${Language.get('Global', 'option_${KadeEngineData.practice}')}', Language.get('GameplayOptions', 'practice_desc'), function()
        {
            KadeEngineData.practice = !KadeEngineData.practice; 
            practice.texto = '${Language.get('GameplayOptions', 'practice_title')} ${Language.get('Global', 'option_${KadeEngineData.practice}')}';
        });
        '\'';

        customize = new KinderButton(407 - 50, 160, Language.get('GameplayOptions', 'customize_title'), Language.get('GameplayOptions', 'customize_desc'), function()
        {
            canDoSomething = false; 
            MusicBeatState.switchState(new options.GameplayCustomizeState());
        });

        ghosttap = new KinderButton(0, 240, (KadeEngineData.settings.data.ghostTap ? '' : 'No ') + "Ghost Tapping", Language.get('GameplayOptions', 'ghosttap_desc'), function()
        {
            KadeEngineData.settings.data.ghostTap = !KadeEngineData.settings.data.ghostTap;
            ghosttap.texto = (KadeEngineData.settings.data.ghostTap) ? "Ghost Tapping" : "No Ghost Tapping";
        });
        ghosttap.screenCenter(X);
    
        buttons.add(downscroll);
        buttons.add(middlescroll);
        buttons.add(practice);
        buttons.add(customize);
        buttons.add(ghosttap);
    }
}
