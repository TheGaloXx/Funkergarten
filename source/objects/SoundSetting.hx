package objects;

import flixel.input.mouse.FlxMouseEvent;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.ui.FlxUISlider;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class SoundSetting extends FlxSpriteGroup
{
    public var isActive(default, set):Null<Bool>;

    function set_isActive(value:Null<Bool>):Null<Bool>
    {
        bg.visible = value;
        slider.visible = value;

        return isActive = value;
    }

    public var soundSprite:FlxSprite;
    public var bg:FlxSprite;  
    public var slider:FlxUISlider;

    private var volumeValue:Null<Float>;
    
    public function new(flipped:Bool = false)
    {
        super();

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

        var offsetX:Int = (!flipped ? 40 : 70);

        slider = new FlxUISlider(this, '', 0, 0, 0, 100, Std.int(bg.width * 0.75), 10, 20, FlxColor.BLACK, FlxColor.GRAY);
        slider.scrollFactor.set();
        slider.hoverSound = slider.clickSound = Paths.sound('scrollMenu', 'preload');
        slider.setTexts("", false, null, null, 32);
        slider.hoverAlpha = 1;
        slider.nameLabel.offset.y = 10;
        slider.nameLabel.font = slider.minLabel.font = slider.maxLabel.font = Paths.font('Crayawn-v58y.ttf');
        slider.valueLabel.visible = false;
        slider.valueLabel.alpha = 0;
        slider.setPosition(bg.x + (bg.width / 2) - (slider.width / 4) - offsetX, bg.y + 30);
        slider.varString = 'volumeValue';
        slider.value = CoolUtil.volume;
        slider.nameLabel.text = Language.get('Global', 'gl_vol');
        add(slider);

        slider.callback = (_) -> 
        {
            if (isActive)
            {
                CoolUtil.changeVolume(volumeValue, true);
                volumeValue = slider.value;
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
        super.destroy();

        FlxMouseEvent.remove(soundSprite);

        isActive = null;
        volumeValue = null;
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