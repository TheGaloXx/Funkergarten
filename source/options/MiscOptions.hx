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

class MiscOptions extends MusicBeatState
{
	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

    var buttons:FlxTypedGroup<KinderButton>;
    var fps:KinderButton;
    var snap:KinderButton;
    var botplay:KinderButton;
    var fullscreen:KinderButton;
    var lockSong:KinderButton;

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

                if      (fps.selected)              versionShit.text = fps.description;
                else if (snap.selected)             versionShit.text = snap.description;
                else if (botplay.selected)          versionShit.text = botplay.description;
                else if (fullscreen.selected)       versionShit.text = fullscreen.description;
                else if (lockSong.selected)         versionShit.text = lockSong.description;
                else                                Language.get('Global', 'options_idle');
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
        fps = new KinderButton(207 - 50, 80, 'FPS: ${Language.get('MiscOptions', 'show_fps_${KadeEngineData.settings.data.fps}')}', Language.get('MiscOptions', 'show_fps_desc'), function()
        {
            KadeEngineData.settings.data.fps = !KadeEngineData.settings.data.fps;
            (cast (Lib.current.getChildAt(0), Main)).toggleFPS(KadeEngineData.settings.data.fps);
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
            FlxG.fullscreen = KadeEngineData.settings.data.fullscreen;
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
        buttons.add(lockSong);
    }
}
