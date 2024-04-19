package substates;

import data.GlobalData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;

class SelectSkinSubstate extends FlxSubState
{
    private var bf1:FlxSprite;
    private var bf2:FlxSprite;
    private var arrow:FlxSprite;
    private var i:Null<Bool> = null;

    public function new()
        super(0xcd000000);

    override function create()
    {
        super.create();

        bf1 = new FlxSprite();
        bf1.frames = Paths.getSparrowAtlas('characters/bf', 'shared');
        bf1.animation.addByPrefix('idle', 'BF idle dance', 0, false);
        bf1.animation.play('idle', true, false, 12);
        bf1.active = false;
        bf1.scrollFactor.set();
        bf1.updateHitbox();
        bf1.screenCenter(Y);
        bf1.x = 100;
        add(bf1);

        bf2 = new FlxSprite();
        bf2.frames = Paths.getSparrowAtlas('characters/bf-alt', 'shared');
        bf2.animation.addByPrefix('idle', 'BF idle dance', 0, false);
        bf2.animation.play('idle', true, false, 12);
        bf2.active = false;
        bf2.scrollFactor.set();
        bf2.updateHitbox();
        bf2.screenCenter(Y);
        bf2.x = FlxG.width - bf2.width - 100;
        add(bf2);

        arrow = new FlxSprite(-2000, 70);
        arrow.frames = Paths.getSparrowAtlas('arrow', 'preload');
        arrow.animation.addByIndices('idle', 'arrow', [1], '', 0, false);
        arrow.angle = 90;
        arrow.active = false;
        arrow.animation.play('idle');
        arrow.scrollFactor.set();
        arrow.updateHitbox();
        add(arrow);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        arrow.x = -2000;
        bf1.alpha = 1;
        bf2.alpha = 1;

        if (FlxG.mouse.overlaps(bf1))
        {
            if (i != true)
                CoolUtil.sound('scrollMenu', 'preload', 0.5);
            i = true;

            CoolUtil.middleSprite(bf1, arrow, X);
            bf1.alpha = 0.75;

            if (FlxG.mouse.justPressed || FlxG.mouse.justPressedRight)
            {
                CoolUtil.sound('confirmMenu', 'preload', 0.7);
                GlobalData.other.usingSkin = false;
                GlobalData.flush();
                close();
            }
        }
        else if (FlxG.mouse.overlaps(bf2))
        {
            if (i != false)
                CoolUtil.sound('scrollMenu', 'preload', 0.5);
            i = false;

            CoolUtil.middleSprite(bf2, arrow, X);
            bf2.alpha = 0.75;

            if (FlxG.mouse.justPressed || FlxG.mouse.justPressedRight)
            {
                CoolUtil.sound('confirmMenu', 'preload', 0.7);
                GlobalData.other.usingSkin = true;
                GlobalData.flush();
                close();
            }
        }
        else
            i = null;

        if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE, SPACE]))
        {
            CoolUtil.sound('cancelMenu', 'preload', 0.5);
            close();
        }
    }
}