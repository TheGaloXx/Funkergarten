package objects;

// I hate this code so much

import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import data.KadeEngineData;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class Yoyo extends FlxTypedSpriteGroup<FlxSprite>
{
    private var parent:FlxTypedGroup<Strum>;
    private var string:FlxSprite;
    private var yoyo:FlxSprite;

    private var centerX:Float;
    private var targetY:Float;
    private var expectedAlpha:Float;
    private var time:Float = 0;

    private var curTarget:Int;

    private var died:Bool = true;
    private var spinning:Bool = false;
    private var fading:Bool = false;

    public function new(strums:FlxTypedGroup<Strum>, camera:flixel.FlxCamera, alpha:Float)
    {
        super();

        for (object in strums.members) centerX += object.x;
        centerX /= strums.length;
        centerX += 90;

        parent = strums;
        targetY = strums.members[0].y;

        string = new FlxSprite().makeGraphic(10, 1, FlxColor.BLACK);
        string.active = false;
        add(string);

        yoyo = new FlxSprite();
        yoyo.frames = Paths.getSparrowAtlas('gameplay/yoyo', 'shared');
        yoyo.animation.addByIndices('idle', 'Yoyo', [0], '', 0, false);
        yoyo.animation.addByIndices('spinning', 'Yoyo', [1, 2, 3, 4], '', 24, true);
        yoyo.animation.play('idle');
        yoyo.setPosition(centerX - (yoyo.width / 2), -yoyo.height);
        add(yoyo);

        this.camera = camera;
        alpha = expectedAlpha = alpha;
        scrollFactor.set();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        time += elapsed;

        if (time > 5)
        {
            time = 0;
            moveX();
        }

        /* no please no
        if (spinning) yoyo.animation.play('spinning');
        else yoyo.animation.play('idle');
        */

        yoyo.alpha = expectedAlpha - (overlaping() ? 0.2 : 0);

        if (!died)
        {
            string.scale.y = (yoyo.y + yoyo.height / 2) * 2;
            string.setPosition(yoyo.x + yoyo.width / 2 - 5, -1);

            if (KadeEngineData.botplay)
            {
                yoyo.alpha = 1;
            }
            else
            {
                if (overlaping() && (FlxG.mouse.justPressed || FlxG.mouse.justPressedRight))
                    die();
            }
        }
        else yoyo.active = yoyo.isOnScreen(yoyo.camera);
    }

    public function play():Void
    {
        if (!died || fading) return;

        died = false;

        FlxTween.cancelTweensOf(yoyo);
        FlxTween.cancelTweensOf(string);

        yoyo.active = true;
        yoyo.velocity.set();
        yoyo.acceleration.set();
        yoyo.setPosition(centerX - (yoyo.width / 2), -yoyo.height);

        FlxTween.tween(yoyo, {y: targetY}, 0.5, {ease: FlxEase.bounceOut, onComplete: function(_)
        {
            moveY();
            if (KadeEngineData.botplay)
            {
                new FlxTimer().start(1.2, function (_)
                {
                    die();
                });
            }
        }});
    }

    private var direction:Bool = true;

    private function moveY():Void
    {
        if (died) return;

        spinning = true;
        direction = !direction;

        FlxTween.tween(yoyo, {y: targetY + (direction ? 0 : (KadeEngineData.settings.data.downscroll ? -400 : 400))}, 1, {ease: FlxEase.backOut, onComplete: function(_)
        {
            moveY();
        }});
    }

    private function moveX():Void
    {
        if (died) return;

        var random = curTarget;

        while(random == curTarget) // Dont tween into the same position, thats stupid
            random = FlxG.random.int(0, parent.members.length - 1);

        curTarget = random;

        FlxTween.tween(yoyo, {x: parent.members[curTarget].x}, 0.5, {ease: FlxEase.quadInOut});
    }

    private function overlaping():Bool
    {
        // FlxG.mouse.overlaps() gets buggy as fuck when changing stuff in cameras

        /*
        return (FlxG.mouse.screenX > (yoyo.getScreenPosition().x) && FlxG.mouse.screenX < (yoyo.getScreenPosition().x + yoyo.width * yoyo.camera.zoom) &&
        FlxG.mouse.screenY > (yoyo.getScreenPosition().y) && FlxG.mouse.screenY < (yoyo.getScreenPosition().y + yoyo.height * yoyo.camera.zoom));
        */

        // I spent hours trying to make this work, but thanks to ✦ Sword ✦ (swordcube) from the official Haxe Discord server it works now!!!
        return yoyo.overlapsPoint(FlxG.mouse.getWorldPosition(yoyo.camera), true, yoyo.camera);
    }

    public function die():Void
    {
        died = true;
        fading = true;
        spinning = false;

        FlxTween.cancelTweensOf(yoyo);
        yoyo.velocity.y = -100;
        yoyo.acceleration.y = 1200;
        yoyo.velocity.x = 100 * (FlxG.random.bool() ? -1 : 1);

        yoyo.scale.set(0.8, 0.8);
        FlxTween.tween(yoyo, {"scale.x": 1, "scale.y": 1}, 0.25, {ease: FlxEase.sineOut});

        FlxTween.cancelTweensOf(string);
        FlxTween.tween(string, {"scale.y": 0}, 1, {ease: FlxEase.quadOut, startDelay: 1, onComplete: function(_)
        {
            fading = false;
        }});
    }
}