package substates;

import options.OptionsMenu;
import data.GlobalData;
import funkin.MusicBeatState;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class OptionsAdviceSubstate extends FlxSubState
{
    var textLeft:FlxText;
    var textRight:FlxText;

	override public function create()
	{
        GlobalData.other.sawAdvice = true;
        GlobalData.flush();

        var bg2 = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        bg2.scale.set(FlxG.width, FlxG.height);
        bg2.updateHitbox();
        bg2.alpha = 0;
        bg2.scrollFactor.set();
        bg2.screenCenter();
        bg2.active = false;
        add(bg2);
        FlxTween.tween(bg2, {alpha: 0.85}, 1);

        var advice = new FlxText(-FlxG.width, 50, FlxG.width - 50, Language.get('WelcomeSubstate', 'welcome_text'), 60);
		advice.scrollFactor.set();
        advice.autoSize = false;
        advice.alignment = LEFT;
        advice.font = Paths.font('Crayawn-v58y.ttf');
        advice.active = false;
        add(advice);
        FlxTween.tween(advice, {x: 50}, 1, {ease: FlxEase.sineOut});

        textLeft = new FlxText(300, FlxG.height, 0, Language.get('WelcomeSubstate', 'go'), 32);
        textLeft.setFormat(flixel.system.FlxAssets.FONT_DEFAULT, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        textLeft.scrollFactor.set();
        add(textLeft);
        FlxTween.tween(textLeft, {y: FlxG.height / 1.75}, 1, {ease: FlxEase.sineOut});

        textRight = new FlxText(FlxG.width - 400, FlxG.height, 0, Language.get('WelcomeSubstate', 'stay'), 32);
        textRight.setFormat(flixel.system.FlxAssets.FONT_DEFAULT, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        textRight.scrollFactor.set();
        add(textRight);
        FlxTween.tween(textRight, {y: FlxG.height / 1.75}, 1, {ease: FlxEase.sineOut});

		super.create();
	}

	override function update(elapsed:Float)
	{
        if (CoolUtil.overlaps(textLeft))
        {
            textLeft.alpha = 0.5;
            textRight.alpha = 1;

            if (FlxG.mouse.justPressed)
            {
                CoolUtil.sound('confirmMenu', 'preload');
                MusicBeatState.switchState(new OptionsMenu(MAIN));
            }
        }
        else if (CoolUtil.overlaps(textRight))
        {
            textLeft.alpha = 1;
            textRight.alpha = 0.5;

            if (FlxG.mouse.justPressed)
            {
                CoolUtil.sound('cancelMenu', 'preload', 0.5);
                close();
            }
        }
        else
        {
            textLeft.alpha = 1;
            textRight.alpha = 1;
        }

        if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
        {
            CoolUtil.sound('cancelMenu', 'preload', 0.5);
            close();
        }

        super.update(elapsed);
    }
}
