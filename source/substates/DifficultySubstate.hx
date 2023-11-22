package substates;

import flixel.text.FlxText;
import states.PlayState;
import funkin.MusicBeatSubstate;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSubState;

class DifficultySubstate extends MusicBeatSubstate
{
    private var text:FlxText;
    private var bg:FlxSprite;
    private var sprites:FlxTypedGroup<FlxSprite>;
    private var curSelected:Int;
    private var transitioning:Bool = true;

    override function create()
    {
        // super.create();

        bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.active = false;
        bg.alpha = 0;
        add(bg);

        FlxTween.tween(bg, {alpha: 0.85}, 1, {ease: FlxEase.expoOut});

        text = new FlxText(0, 50, FlxG.width, Language.get('Global', 'diff_text'), 68);
		text.scrollFactor.set();
        text.autoSize = false;
		text.setFormat(Paths.font('Crayawn-v58y.ttf'), 68, FlxColor.YELLOW, CENTER, OUTLINE, FlxColor.BLACK);
		text.borderSize = 4;
        text.alpha = 0;
        text.active = false;
        add(text);

        FlxTween.tween(text, {alpha: 1}, 1, {ease: FlxEase.expoOut});

        sprites = new FlxTypedGroup<FlxSprite>();
        add(sprites);

        final atlas = Paths.getSparrowAtlas('menu/difficulties', 'preload');        

        for (i in 0...3)
        {
            var daY:Float = 0;

            var sprite = new FlxSprite(100, 0);
            sprite.frames = atlas;
            sprite.animation.addByPrefix('idle', ['easy', 'normal', 'hard'][i], 0, false);
            sprite.animation.play('idle');
            sprite.updateHitbox();
            sprite.active = false;
            sprite.scale.set(0.9, 0.9);
            sprite.ID = i;
            sprites.add(sprite);

            daY = 100;
            switch (i)
            {
                case 1:
                    daY = FlxG.height - sprite.height - 30;
                    sprite.screenCenter(X);
                case 2:
                    sprite.x = FlxG.width - sprite.width - 100;
            }

            sprite.y = daY + FlxG.height;

            FlxTween.tween(sprite, {y: daY}, 1, {ease: FlxEase.expoOut, onComplete: function(_) transitioning = false});
        }

        atlas.destroy();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (transitioning)
            return;

        if (controls.BACK)
        {
            CoolUtil.sound('cancelMenu', 'preload', 0.5);
            transitioning = true;
            close();
        }

        if (FlxG.mouse.overlaps(sprites))
        {
            for (sprite in sprites.members)
            {
                if (FlxG.mouse.overlaps(sprite))
                {
                    curSelected = sprite.ID;
                }
            }

            if (FlxG.mouse.justPressed || FlxG.mouse.justPressedRight)
                go();
        }
        else
        {
            curSelected = -1;
        }

        for (sprite in sprites.members)
        {
            if (sprite.ID != curSelected)
            {
                sprite.scale.set(0.9, 0.9);
                continue;
            }

            final mult:Float = FlxMath.lerp(1, sprite.scale.x, CoolUtil.boundTo(1 - (elapsed * 9)));
            sprite.scale.set(mult, mult);
        }
    }

    private function go():Void
    {
        if (transitioning)
            return;

        transitioning = true;
        PlayState.storyDifficulty = curSelected;
        CoolUtil.sound('confirmMenu', 'preload');

        for (sprite in sprites.members)
            if (sprite.ID != curSelected)
                FlxTween.tween(sprite, {y: sprite.y + FlxG.height}, 0.75, {ease: FlxEase.backOut});

        FlxTween.tween(text, {alpha: 0}, 1, {ease: FlxEase.sineOut});
        FlxTween.tween(bg, {alpha: 1}, 1, {ease: FlxEase.sineOut, onComplete: function(_)
        {
            FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, function()
            {
                world.RoomState.tellMonday = true;
                funkin.MusicBeatState.switchState(new world.RoomState());
                FlxG.sound.music.stop();
            });
        }});
    }
}
