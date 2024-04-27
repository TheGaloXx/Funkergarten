package options;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.sound.FlxSound;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import openfl.Lib;
import states.LanguageState;
import objects.SoundSetting;
import states.PlayState;
import states.MainMenuState;
import substates.PauseSubState;
import funkin.MusicBeatState;
import data.GlobalData;
import flixel.FlxState;
import objects.KinderButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class OptionsMenu extends MusicBeatState
{
    public static var instance:OptionsMenu;
    public var acceptInput(default, set):Bool = false;
    public var text:DescriptionBox;

    private var buttons:FlxTypedGroup<KinderButton>;
    private var stuff:Map<String, Float> = [];
    private var data:SettingsData = GlobalData.settings;
    private var type:Options;

    override public function new(type:Options)
    {
        super();

        this.type = type;
    }

	override function create()
	{
        instance = this;

		CoolUtil.title('Options Menu');
		CoolUtil.presence(null, Language.get('Discord_Presence', 'options_menu'), false, 0, null);

		final time = Date.now().getHours();

		var bg = new FlxSprite();
        bg.frames = Paths.getSparrowAtlas('menu/credits_assets', 'preload');
		bg.animation.addByPrefix('idle', 'paper', 0, false);
		bg.animation.play('idle');
		bg.active = false;
		add(bg);

        if (time > 19 || time < 8)
			bg.alpha = 0.7;

        var paper = new FlxSprite().loadGraphic(Paths.image('menu/page', 'preload'));
        paper.screenCenter();
        paper.active = false;
        add(paper);

        buttons = new FlxTypedGroup<KinderButton>();
        add(buttons);

        text = new DescriptionBox();
        add(text);

        for (i in 0...6)
        {
            var button:KinderButton = new KinderButton(0, -3000, '');
            button.active = false;
            button.visible = false;
            buttons.add(button);
        }

        reset(type);

        add(new SoundSetting(true));

		super.create();
	}

	override function update(elapsed:Float)
	{
        if (!acceptInput)
            return;

        super.update(elapsed);

        if (controls.BACK)
        {
            CoolUtil.sound('cancelMenu', 'preload', 0.5);

            acceptInput = false;

            if (type == MAIN)
            {
                if (!PauseSubState.options)
                    MusicBeatState.switchState(new MainMenuState());
                else
                {
                    PauseSubState.options = false;
                    MusicBeatState.switchState(new PlayState());
                }
            }
            else
            {
                GlobalData.flush();
                reset(MAIN);
            }
        }
	}

    private function addButton(text:String, ?id:String):KinderButton
    {
        stuff.set("i", stuff.get("i") + 1);

        if (type == MAIN)
        {
            stuff.set("x", 514); // stay in the center
            stuff.set("y", 12 + stuff.get("y") + 160);
        }
        else
        {
            if (stuff.get("i") % 2 == 0)
            {
                stuff.set("y", stuff.get("y") + 160);
            }

            if (stuff.get("x") == 714)
            {
                stuff.set("x", 314);
            }
            else
            {
                stuff.set("x", 714);
            }
        }

        var button:KinderButton = buttons.members[Std.int(stuff.get("i"))];
        button.setup(stuff.get('x'), stuff.get('y'), text);
        button.visible = true;
        button.active = true;

        if (id != null)
            button.description = getLang('${id}_description');

        return button;
    }

    private function reset(menu:Options):Void
    {
        this.type = menu;

        stuff = 
        [
            "i" => -1,
            "x" => 357,
            "y" => 0
        ];

        buttons.forEach((curButton:KinderButton) ->
        {
            curButton.active = false;
            curButton.visible = false;
            curButton.description = '';
        });

        switch (menu)
        {
            case MAIN:
                addButton("Gameplay").callback = function()
                    reset(GAMEPLAY);

                addButton(getLang('appearance')).callback = function()
                    reset(APPEARANCE);

                addButton(getLang('other')).callback = function()
                    reset(MISC);

            case GAMEPLAY:
                addButton(getLang('controls_title'), 'controls').callback = function()
                {
                    acceptInput = false;

                    openSubState(new KeyBindMenu());
                }

                var mechanic = addButton('${getLang('mechanics_title')} ${getToggle(data.mechanicsEnabled)}', 'mechanics');
                mechanic.callback = function()
                {
                    data.mechanicsEnabled = !data.mechanicsEnabled;
                    mechanic.text = '${getLang('mechanics_title')} ${getToggle(data.mechanicsEnabled)}';
                };

                var downscroll = addButton((data.downscroll ? 'Downscroll' : 'Upscroll'), 'downscroll');
                downscroll.callback = function()
                {
                    data.downscroll = !data.downscroll;
                    downscroll.text = (data.downscroll ? 'Downscroll' : 'Upscroll');
                };

                var middlescroll = addButton('Middlescroll: ${getToggle(data.middlescroll)}', 'middlescroll');
                middlescroll.callback = function()
                {
                    data.middlescroll = !data.middlescroll;
                    middlescroll.text = 'Middlescroll: ${getToggle(data.middlescroll)}';
                };

                var customize = addButton(getLang('customize_title'), 'customize');
                customize.callback = function()
                {
                    acceptInput = false;

                    MusicBeatState.switchState(new GameplayCustomizeState());
                };

                var ghosttap = addButton('Ghost tapping: ${getToggle(data.ghostTapping)}', 'ghost');
                ghosttap.callback = function()
                {
                    data.ghostTapping = !data.ghostTapping;
                    ghosttap.text = 'Ghost tapping: ${getToggle(data.ghostTapping)}';
                };

            case APPEARANCE:
                var antialiasing = addButton('Antialiasing: ${getToggle(data.antialiasingEnabled)}', 'antialiasing');
                antialiasing.callback = function()
                {
                    data.antialiasingEnabled = !data.antialiasingEnabled;
                    antialiasing.text = 'Antialiasing: ${getToggle(data.antialiasingEnabled)}';
                    FlxSprite.defaultAntialiasing = data.antialiasingEnabled; // how did i forget this
                }

                var flashing = addButton('${getLang('flashing_title')} ${getToggle(data.flashingLights)}', 'flashing');
                flashing.callback = function()
                {
                    data.flashingLights = !data.flashingLights;
                    flashing.text = '${getLang('flashing_title')} ${getToggle(data.flashingLights)}';
                };

                var shaders = addButton('Shaders: ${getToggle(data.shadersEnabled)}', 'shaders');
                shaders.callback = function()
                {
                    data.shadersEnabled = !data.shadersEnabled;
                    shaders.text = 'Shaders: ${getToggle(data.shadersEnabled)}';
                }

                var camMove = addButton('${getLang('cam_title')} ${getToggle(data.singCamMoveEnabled)}', 'cam');
                camMove.callback = function()
                {
                    data.singCamMoveEnabled = !data.singCamMoveEnabled;
                    camMove.text = '${getLang('cam_title')} ${getToggle(data.singCamMoveEnabled)}';
                }

                var lowQuality = addButton('${getLang('quality_title')} ${getToggle(data.lowQuality)}', 'quality');
                lowQuality.callback = function()
                {
                    data.lowQuality = !data.lowQuality;
                    lowQuality.text = '${getLang('quality_title')} ${getToggle(data.lowQuality)}';
                };

                var zooms = addButton('${getLang('zooms_title')} ${getToggle(data.camZoomsEnabled)}', 'zooms');
                zooms.callback = function()
                {
                    data.camZoomsEnabled = !data.camZoomsEnabled;
                    zooms.text = '${getLang('zooms_title')} ${getToggle(data.camZoomsEnabled)}';
                };

            case MISC:
                addButton(getLang('language'), 'language').callback = function()
                {
                    acceptInput = false;

                    MusicBeatState.switchState(new LanguageState(true));
                };

                var fps = addButton('FPS: ${getLang('show_fps_${data.showFPS}')}', 'show_fps');
                fps.callback = function()
                {
                    data.showFPS = !data.showFPS;

                    cast (Lib.current.getChildAt(0), Main).toggleFPS(data.showFPS);

                    fps.text = 'FPS: ${getLang('show_fps_${data.showFPS}')}';
                }

                var fullscreen = addButton(getLang('fullscreen_title_${FlxG.fullscreen}'), 'fullscreen');
                fullscreen.callback = function()
                {
                    FlxG.fullscreen = !FlxG.fullscreen;
                    data.fullscreen = FlxG.fullscreen;
                    fullscreen.text = getLang('fullscreen_title_${FlxG.fullscreen}');
                };

                var fpsCap = addButton('${getLang('fps_cap')} ' + data.fpsCap, 'fps_cap');
                fpsCap.callback = function()
                {
                    data.fpsCap += 60;

                    if (data.fpsCap > 240)
                        data.fpsCap = 60;

                    fpsCap.text = '${getLang('fps_cap')} ' + data.fpsCap;

                    Main.changeFPS(data.fpsCap);
                };

                addButton(getLang('colorblind_title'), 'colorblind').callback = function()
                {
                    acceptInput = false;

                    MusicBeatState.switchState(new ColorblindMenu());
                };

                addButton(getLang('reset_data'), 'reset_data').callback = function()
                {
                    acceptInput = false;

                    openSubState(new EraseData());
                };
        }

        FlxTween.cancelTweensOf(FlxG.camera, ['zoom']);
        FlxG.camera.zoom = 1.01;
        FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {ease: FlxEase.circOut});

        text.setDescription();
        acceptInput = true;
    }

    function set_acceptInput(value:Bool):Bool
    {
        acceptInput = value;

        buttons.forEach((curButton:KinderButton) ->
        {
            curButton.active = value;
            
            @:privateAccess
            curButton.selected = false;
        });

        return value;
    }

    private inline function getLang(id:String):String
    {
        return Language.get(Std.string(type) + 'Options', id);
    }

    private inline function getToggle(condition:Bool):String
    {
        return Language.get('Global', 'option_$condition');
    }
}

private class DescriptionBox extends FlxSpriteGroup
{
    public var box:FlxSprite;
    public var text:FlxText;
    public var description:String;

    private var time:Float = 0;

    private static inline final _offset:Int = 15;
    private static inline final speed:Float = 7;

    public function new()
    {
        super();

        box = new FlxSprite(_offset);
        box.makeGraphic(1, 1);
        box.color = FlxColor.BLACK;
        box.alpha = 0.75;
        box.scale.set(FlxG.width - 150 - _offset, 0);
        box.updateHitbox();
        box.active = false;
        add(box);

        text = new FlxText(_offset, 0, FlxG.width - 150 - _offset, '', 42);
        text.font = Paths.font('Crayawn-v58y.ttf');
        text.active = false;
        text.autoSize = false;
        text.alignment = CENTER;
        add(text);

        setDescription();
    }

    override function update(elapsed:Float):Void
    {
        // super.update(elapsed);

        if (!visible)
            return;

        time += elapsed * speed;

        y += Math.sin(time) * elapsed * speed;
    }

    public function setDescription(?description:String):Void
    {
        if (this.description == description)
            return;

        this.description = description;

        if (description == null || description.length <= 0)
        {
            visible = false;
            return;
        }
        else
            visible = true;

        text.text = description;

        box.scale.y = text.height;
        box.updateHitbox();

        y = FlxG.height - height - _offset / 2;
    }
}

private enum Options
{
    MAIN;
    GAMEPLAY;
    APPEARANCE;
    MISC;
}