package options;

import data.GlobalData;
import openfl.filters.ColorMatrixFilter;
import funkin.MusicBeatState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;

class ColorblindMenu extends MusicBeatState
{
    private var arrows:Array<FlxSprite> = [];
    private var text:FlxText;
    private var leaving:Bool = true;
    private var curSelected:Int = 0;

    private final typesArray:Array<String> = ['No filter', 'Protanopia filter', 'Protanomaly filter', 'Deuteranopia filter', 'Deuteranomaly filter', 'Tritanopia filter', 'Tritanomaly filter', 'Achromatopsia filter', 'Achromatomaly filter'];
    
    // Took these values from Indie Cross: https://github.com/brightfyregit/Indie-Cross-Public/blob/master/source/Shaders.hx#L216C12-L217C1
    public static final typesMap:Map<String, Array<Float>> = 
    [
        'No filter' =>
        [

        ],
        'Protanopia filter' => 
        [
            0.567, 0.433, 0,
            0, 0,
            0.558, 0.442, 0,
            0, 0,
            0, 0.242, 0.758,
            0, 0,
            0, 0, 0, 1, 0
        ],
        'Protanomaly filter' =>
        [
            0.817, 0.183, 0,
            0, 0,
            0.333, 0.667, 0,
            0, 0,
            0, 0.125, 0.875,
            0, 0,
            0, 0, 0, 1, 0
        ],
        'Deuteranopia filter' =>
        [
            0.625, 0.375, 0,
            0, 0,
            0.7, 0.3, 0,
            0, 0,
            0, 0, 1.0,
            0, 0,
            0, 0, 0, 1, 0
        ],
        'Deuteranomaly filter' =>
        [
            0.8, 0.2, 0,
            0, 0,
            0.258, 0.742, 0,
            0, 0,
            0, 0.142, 0.858,
            0, 0,
            0, 0, 0, 1, 0
        ],
        'Tritanopia filter' =>
        [
            0.95, 0.05, 0,
            0, 0,
            0, 0.433, 0.567,
            0, 0,
            0, 0.475, 0.525,
            0, 0,
            0, 0, 0, 1, 0
        ],
        'Tritanomaly filter' =>
        [
            0.967, 0.033, 0,
            0, 0,
            0, 0.733, 0.267,
            0, 0,
            0, 0.183, 0.817,
            0, 0,
            0, 0, 0, 1, 0
        ],
        'Achromatopsia filter' =>
        [
            0.299, 0.587, 0.114,
            0, 0,
            0.299, 0.587, 0.114,
            0, 0,
            0.299, 0.587, 0.114,
            0, 0,
            0, 0, 0, 1, 0
        ],
        'Achromatomaly filter' =>
        [
            0.618, 0.320, 0.062,
            0, 0,
            0.163, 0.775, 0.062,
            0, 0,
            0.163, 0.320, 0.516,
            0, 0,
            0, 0, 0, 1, 0
        ]
    ];

    override function create()
    {
        super.create();

        var background = new FlxSprite(0, 0, Paths.image('colorblindBG', 'preload'));
        background.active = false;
        background.scrollFactor.set();
        add(background);

        var blackBar = new FlxSprite(0, FlxG.height - 115).makeGraphic(1, 1, FlxColor.BLACK);
        blackBar.scale.y = 95; // 46
        blackBar.updateHitbox();
		blackBar.scrollFactor.set();
        blackBar.active = false;
        blackBar.alpha = 0.7;
        blackBar.origin.x = 0.5;
		add(blackBar);

        for (i in 0...2)
        {
            var arrow = new FlxSprite();
            arrow.frames = Paths.getSparrowAtlas('arrow', 'preload');
            arrow.animation.addByIndices('idle', 'arrow', [0], '', 0, false, (i == 0 ? true : false));
            arrow.animation.addByIndices('pressed', 'arrow', [1], '', 0, false, (i == 0 ? true : false));
            arrow.active = false;
            arrow.visible = false;
            arrow.animation.play('idle');
            arrow.updateHitbox();
            arrow.setPosition((i == 0 ? FlxG.width * 0.3 : FlxG.width * 0.7 - arrow.width), (blackBar.y + (blackBar.height / 2)) - (arrow.height / 2));
            arrows.push(arrow);
            add(arrow);
        }

		text = new FlxText(0, 0, FlxG.width, '', 44);
        text.autoSize = false;
        text.alignment = CENTER;
		text.scrollFactor.set();
        text.font = Paths.font('Crayawn-v58y.ttf');
        text.alpha = 0;
        text.active = false;
        CoolUtil.middleSprite(blackBar, text, Y);
		add(text);

        blackBar.scale.y = 1;
        blackBar.updateHitbox();

        FlxTween.tween(blackBar, {"scale.x": FlxG.width * 0.8, "scale.y": 95}, 0.7, {startDelay: 0.5, ease: FlxEase.sineOut, onUpdate: function(_)
        {
            blackBar.updateHitbox();
            blackBar.x = (FlxG.width - blackBar.scale.x) * 0.5;
        }, onComplete: function(_)
        {
            FlxTween.tween(text, {alpha: 1}, 0.2, {ease: FlxEase.circOut, onComplete: function(_)
            {
                for (i in arrows) i.visible = true;
                leaving = false;
            }});
        }});

        init();
    }

    override function update(elapsed:Float):Void
    {
        if (leaving)
            return;

        super.update(elapsed);

        if (controls.BACK)
        {
            CoolUtil.sound('cancelMenu', 'preload', 0.5);
            leaving = true;

            GlobalData.settings.colorblindType = typesArray[curSelected];
            GlobalData.flush();

            MusicBeatState.switchState(new MiscOptions(new KindergartenOptions(null)));
        }

        var left = FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT;
		var right = FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT;

        final leftP = FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A;
        final rightP = FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D;

        final leftR = FlxG.keys.justReleased.LEFT || FlxG.keys.justReleased.A;
        final rightR = FlxG.keys.justReleased.RIGHT || FlxG.keys.justReleased.D;

        if (leftP || rightP)
        {
            arrows[0].animation.play((leftP ? 'pressed' : 'idle'));
            arrows[1].animation.play((rightP ? 'pressed' : 'idle'));
        }

        if (leftR)
            arrows[0].animation.play('idle');
        if (rightR)
            arrows[1].animation.play('idle');

        if (left && right)
			left = right = false;

        if (left)
            changeSelection(false);
        if (right)
            changeSelection(true);
    }

    private function changeSelection(right:Bool):Void
    {
        curSelected += (right ? 1 : -1);

        if (curSelected > typesArray.length - 1)
            curSelected = 0;
        else if (curSelected < 0)
            curSelected = typesArray.length - 1;

        final type = typesArray[curSelected];

        text.text = Language.get('Colorblind_Types', type);

        if (type == 'No filter')
            FlxG.game.setFilters([]);
        else
            FlxG.game.setFilters([new ColorMatrixFilter(typesMap.get(type))]);

        CoolUtil.sound('scrollMenu', 'preload', 0.7);
    }

    private inline function init():Void
    {
        curSelected = typesArray.indexOf(GlobalData.settings.colorblindType);
        text.text = Language.get('Colorblind_Types', typesArray[curSelected]);

        CoolUtil.sound('scrollMenu', 'preload', 0.7);
    }
}