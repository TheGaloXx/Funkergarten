package options;

import data.KadeEngineData;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.BitmapFilter;
import funkin.MusicBeatState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxSprite;

class ColorblindMenu extends MusicBeatState
{
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

        var blackBar = new FlxSprite(0, FlxG.height - 46).makeGraphic(1, 1, FlxColor.BLACK);
        blackBar.scale.y = 46;
		blackBar.scrollFactor.set();
        blackBar.active = false;
        blackBar.alpha = 0.7;
        blackBar.origin.x = 0.5;
		add(blackBar);

		text = new FlxText(0, FlxG.height - 40, FlxG.width, '', 44);
        text.autoSize = false;
        text.alignment = CENTER;
		text.scrollFactor.set();
        text.font = Paths.font('Crayawn-v58y.ttf');
        text.alpha = 0;
        text.active = false;
		add(text);

        FlxTween.tween(blackBar, {"scale.x": FlxG.width}, 0.7, {startDelay: 0.5, ease: FlxEase.sineOut, onUpdate: function(_)
        {
            blackBar.updateHitbox();
            blackBar.x = (FlxG.width - blackBar.scale.x) * 0.5;
        }, onComplete: function(_)
        {
            FlxTween.tween(text, {alpha: 1}, 0.2, {ease: FlxEase.circOut, onComplete: function(_)
            {
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
            leaving = true;

            KadeEngineData.settings.data.colorblind = typesArray[curSelected];
            KadeEngineData.flush();

            MusicBeatState.switchState(new MiscOptions(new KindergartenOptions(null)));
        }

        if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
            changeSelection(false);
        else if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
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

        text.text = type;

        if (type == 'No filter')
            FlxG.game.setFilters([]);
        else
            FlxG.game.setFilters([new ColorMatrixFilter(typesMap.get(type))]);

        CoolUtil.sound('scrollMenu', 'preload', 0.7);
    }

    private inline function init():Void
    {
        curSelected = typesArray.indexOf(KadeEngineData.settings.data.colorblind);
        text.text = typesArray[curSelected];

        CoolUtil.sound('scrollMenu', 'preload', 0.7);
    }
}