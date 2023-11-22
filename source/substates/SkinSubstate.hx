package substates;

import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxSubState;

class SkinSubstate extends FlxSubState
{
    private var blackScreen:FlxSprite;
    private var bf:FlxSprite;
    private var text:FlxText;
    private var bg:FlxBackdrop;
    private var leaving:Bool = true;

    override function create()
    {
        super.create();

        FlxG.sound.music.fadeOut(0.3, 0, function(_) new FlxSound().loadEmbedded(Paths.music('gameOverEnd', 'shared'), false, true, function() FlxG.sound.music.fadeIn(1)).play());

        blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        blackScreen.scale.set(FlxG.width, FlxG.height);
        blackScreen.updateHitbox();
        blackScreen.active = false;
        blackScreen.alpha = 0;
        blackScreen.scrollFactor.set();
        add(blackScreen);

        var grid = FlxGridOverlay.create(Std.int(FlxG.width / 14), Std.int(FlxG.width / 14), Std.int(FlxG.width / 14) * 2, Std.int(FlxG.width / 14) * 2, true, FlxColor.BLACK, FlxColor.GRAY);

        bg = new FlxBackdrop(grid.graphic);
        bg.velocity.set(100, 100);
        bg.color = FlxColor.YELLOW;
        bg.blend = ADD;
        bg.active = false;
        bg.alpha = 0;
        bg.scrollFactor.set();
        add(bg);

        grid.destroy();

        bf = new FlxSprite();
        bf.frames = Paths.getSparrowAtlas('characters/bf-alt', 'shared');
        bf.animation.addByPrefix('idle', 'BF idle dance', 0, false);
        bf.animation.play('idle', true, false, 12);
        bf.active = false;
        bf.scrollFactor.set();
        bf.updateHitbox();
        bf.screenCenter();
        bf.scale.set();
        add(bf);

        text = new FlxText(0, 0, FlxG.width, Language.get('Global', 'skin_text'), 68);
		text.scrollFactor.set();
        text.autoSize = false;
		text.setFormat(Paths.font('Crayawn-v58y.ttf'), 68, FlxColor.YELLOW, CENTER, OUTLINE, FlxColor.BLACK);
		text.borderSize = 4;
        text.alpha = 0;
        text.active = false;
        text.screenCenter(Y);
        add(text);

        FlxTween.tween(blackScreen, {alpha: 0.5}, 1, {ease: FlxEase.sineOut, startDelay: 0.1});
        FlxTween.tween(bg, {alpha: 0.25}, 1, {ease: FlxEase.sineOut, startDelay: 0.1});
        FlxTween.tween(bf, {"scale.x": 1, "scale.y": 1}, 0.9, {ease: FlxEase.backOut, startDelay: 0.2});
        FlxTween.tween(text, {alpha: 1}, 1, {ease: FlxEase.sineOut, startDelay: 0.1, onComplete: function(_) leaving = false});
    }

    override function update(elapsed:Float):Void
    {
        @:privateAccess
        bg.updateMotion(elapsed);

        if (leaving)
            return;

        super.update(elapsed);

        if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE, ENTER, SPACE]) || FlxG.mouse.justPressed || FlxG.mouse.justPressedRight)
        {
            leaving = true;
            CoolUtil.sound('cancelMenu', 'preload', 0.5);
            FlxTween.tween(blackScreen, {alpha: 0}, 0.3, {ease: FlxEase.sineOut});
            FlxTween.tween(bg, {alpha: 0}, 0.3, {ease: FlxEase.sineOut});
            FlxTween.tween(bf, {"scale.x": 0, "scale.y": 0}, 0.2, {ease: FlxEase.sineOut});
            FlxTween.tween(text, {alpha: 0}, 0.3, {ease: FlxEase.sineOut, onComplete: function(_) close()});
        }
    }
}