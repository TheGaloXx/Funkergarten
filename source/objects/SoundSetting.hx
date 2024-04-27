package objects;

import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxSpriteUtil;
import flixel.input.mouse.FlxMouseEvent;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.ui.FlxUISlider;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class SoundSetting extends FlxSpriteGroup
{
    public static var instance:SoundSetting;

    public var isActive(default, set):Null<Bool>;

    function set_isActive(value:Null<Bool>):Null<Bool>
    {
        bg.visible = value;
        slider.visible = value;

        return isActive = value;
    }

    public var soundSprite:FlxSprite;
    public var bg:FlxSprite;  
    public var slider:Slider;
    
    public function new(flipped:Bool = false)
    {
        super();

        instance = this;

        soundSprite = new FlxSprite();
        soundSprite.frames = Paths.getSparrowAtlas('menu/soundSprite', 'preload');
        soundSprite.animation.addByPrefix('idle', 'soundSprite', 12, true); //yes, its 12 fps, its intentional 
        soundSprite.animation.play('idle');
        soundSprite.active = false;
        soundSprite.scrollFactor.set();
        add(soundSprite);

        FlxMouseEvent.add(soundSprite, onClick, null, null, null, false, true, false);

        bg = new FlxSprite();
        bg.frames = Paths.getSparrowAtlas('menu/soundBg', 'preload');
        bg.animation.addByPrefix('idle', 'soundBg', 12, true); //yes, its 12 fps, its intentional 
        bg.animation.play('idle');
        bg.scrollFactor.set();
        add(bg);

        soundSprite.flipX = flipped;
        bg.flipX = flipped;

        if (!flipped)
        {
            soundSprite.setPosition(5, FlxG.height - soundSprite.width - 5);
            bg.setPosition(soundSprite.x + soundSprite.width, soundSprite.y - bg.height + 5);
        }
        else
        {
            soundSprite.setPosition(FlxG.width - soundSprite.width - 5, FlxG.height - soundSprite.width - 5);
            bg.setPosition(soundSprite.x - bg.width, soundSprite.y - bg.height + 5);
        }

        var offsetX:Int = (!flipped ? 60 : 87);

        slider = new Slider(Std.int(bg.width * 0.75), Language.get('Global', 'gl_vol'));        
        slider.setPosition(bg.x + (bg.width / 2) - (slider.width / 4) - offsetX, bg.y + slider.height + 15);
        add(slider);

        slider.callback = (volume) -> 
        {
            if (isActive)
            {
                CoolUtil.changeVolume(volume, true);
            }
        }

        isActive = false;
    }

    override function update(elapsed:Float)
    {
        soundSprite.updateAnimation(elapsed);

        if (!isActive)
            return;

        super.update(elapsed);

        if (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(this))
        {
            isActive = false;
            CoolUtil.sound('cancelMenu', 'preload', 0.5);
        }
    }

    override function destroy():Void
    {
        instance = null;

        super.destroy();

        FlxMouseEvent.remove(soundSprite);

        isActive = null;
    }

    private function onClick(_):Void
    {
        if (isActive)
            CoolUtil.sound('cancelMenu', 'preload', 0.5);
        else
            CoolUtil.sound('scrollMenu', 'preload');

        isActive = !isActive;
    }
}

private class Slider extends FlxSpriteGroup
{
    public var callback:Float->Void;

    private var bar:FlxSprite;
    private var ball:FlxSprite;
    private var holding:Bool = false;
    private var text:FlxText;
    private var rect:FlxRect;

    public function new(width:Int, name:String)
    {
        super();

        rect = FlxRect.get();

        bar = new FlxSprite();
        bar.makeGraphic(width * 4, 10 * 4, 0, false, 'SLIDER_BAR'); // make it 4 times the size and then make it smaller with scale so it doesnt look pixelated
        bar.active = false;
        add(bar);

        FlxSpriteUtil.drawRoundRect(bar, 0, 0, bar.width, bar.height, 10 * 4, 10 * 4, 0xff575757);
        bar.setGraphicSize(bar.width / 4);
        bar.updateHitbox();

        ball = new FlxSprite();
        ball.makeGraphic(Std.int(bar.height * 1.25) * 4, Std.int(bar.height * 1.25) * 4, 0, false, 'SLIDER_BALL');
        ball.active = false;
        add(ball);

        FlxSpriteUtil.drawCircle(ball, -1, -1, ball.width / 2, FlxColor.BLACK);
        ball.setGraphicSize(ball.width / 4);
        ball.updateHitbox();

        ball.y = bar.y + (bar.height - ball.height) / 2;

        text = new FlxText(0, 0, bar.width, name, 36);
		text.autoSize = false;
		text.setFormat(Paths.font('Crayawn-v58y.ttf'), 36, FlxColor.BLACK, CENTER);
		text.active = false;
		add(text);

        text.y -= text.height + 10;

        updatePosition(CoolUtil.volume);
    }

    override function update(elapsed:Float):Void
    {
        // super.update(elapsed);

        if (holding && FlxG.mouse.justReleased)
        {
            holding = false;

            return;
        }

        if (FlxG.mouse.justPressed && !holding && FlxG.mouse.overlaps(this))
        {
            holding = true;

            updatePosition();

            if (callback != null)
            {
                callback(getVolume());
            }

            CoolUtil.sound('scrollMenu', 'preload', 0.4);
        }

        if (holding)
        {
            updatePosition();

            if (FlxG.mouse.justMoved)
            {
                if (callback != null)
                {
                    callback(getVolume());
                }
            }
        }
    }

    private inline function getVolume():Float
    {
        var rawVolume:Float = (ball.x - this.x + ball.width / 2) / (bar.width - ball.width);
        var percent:Float = rawVolume * 100;
        var finalVolume:Float = FlxMath.bound(percent, 0, 100);

        return finalVolume;
    }

    public function updatePosition(?fromVolume:Float):Void
    {
        if (fromVolume != null)
        {
            var newX:Float = (fromVolume / 100) * (bar.width - ball.width) + this.x - ball.width / 2;
            ball.x = newX;
        }
        else
        {
            ball.x = FlxG.mouse.getWorldPosition().x - ball.width / 2;
        }

        ball.x = FlxMath.bound(ball.x, this.x - (ball.width / 2), this.x + bar.width - (ball.width / 2));
    }

    override function destroy():Void
    {
        rect.put();

        super.destroy();
    }
}