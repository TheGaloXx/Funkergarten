package options;

import flixel.graphics.frames.FlxAtlasFrames;
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

// TODO: make language getting more typo proof and dynamic (example use the Type/Class name shit) - lo pongo aqui porque es el primero que hice xd
class AppearanceOptions extends MusicBeatState
{
	public var canDoSomething:Bool = true;

	public static var versionShit:FlxText;

	var blackBorder:FlxSprite;

    var buttons:FlxTypedGroup<KinderButton>;
    var antialiasing:KinderButton;
    var shaders:KinderButton;
    var camMove:KinderButton;
    var distractions:KinderButton;
    var accuracyDisplay:KinderButton;
    var songPosition:KinderButton;

    var tex:FlxAtlasFrames;
	var bf:FlxSprite;
	var a:FlxText;

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

        bf = new FlxSprite();
		var tex = Paths.getSparrowAtlas('characters/bf', 'shared');
		bf.frames = tex;
		bf.animation.addByPrefix('idle', 'BF idle dance', 24, true);
		bf.scale.set(0.4, 0.4);
		bf.updateHitbox();
		bf.setPosition(FlxG.width - bf.width, FlxG.height - bf.height);
		bf.animation.play('idle', true);
		bf.visible = false;
		add(bf);

		a = new FlxText();
		a.alignment = CENTER;
		a.size = 25;
		a.x = 1046;
		a.y = 685.5;
		a.color = 0xffffffff;
		a.visible = false;
        a.text = (KadeEngineData.settings.data.antialiasing ? "antialiasing on" : "antialiasing off");
		add(a);

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
                //yo what the fuck is this

                if (!antialiasing.selected) {   bf.visible = false;  a.visible = false;}

                if      (antialiasing.selected){    versionShit.text = antialiasing.description;    bf.visible = true; a.visible = true;    }
                else if (shaders.selected)          versionShit.text = shaders.description;
                else if (camMove.selected)          versionShit.text = camMove.description; 
                else if (distractions.selected)     versionShit.text = distractions.description;
                else if (accuracyDisplay.selected)  versionShit.text = accuracyDisplay.description;
                else if (songPosition.selected)     versionShit.text = songPosition.description;
                else                                versionShit.text = Language.get('Global', 'options_idle');
            }
            else
            {
                versionShit.text = "";

                bf.visible = false;  a.visible = false;

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

        antialiasing = new KinderButton(207 - 50, 80, 'Antialiasing: ${Language.get('Global', 'option_${KadeEngineData.settings.data.antialiasing}')}', Language.get('AppearanceOptions', 'antialiasing_desc'), function()
        {
            KadeEngineData.settings.data.antialiasing = !KadeEngineData.settings.data.antialiasing;
            var antialias:Bool = KadeEngineData.settings.data.antialiasing;
            flixel.FlxSprite.defaultAntialiasing = antialias;
            bf.antialiasing = antialias;
            a.antialiasing = antialias;
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
}
