import flixel.FlxBasic;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.ui.FlxUISlider;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class SoundSetting extends FlxSpriteGroup
{
    public var soundSprite:FlxSprite;
    public var bg:FlxSprite;  
    public var flipped:Bool = false;
    public var isActive:Bool = false;
    var visibleShit:FlxSpriteGroup;
    var sliders:FlxTypedGroup<FlxUISlider>;

    var generalValue:Float;
    var musicValue:Float;
    var soundValue:Float;
    
    public function new(flipped:Bool = false)
        {
            super();

            this.flipped = flipped;

            soundSprite = new FlxSprite();
            soundSprite.frames = Paths.getSparrowAtlas('menu/soundSprite');
            soundSprite.animation.addByPrefix('idle', 'soundSprite', 12, true); //yes, its 12 fps, its intentional 
            soundSprite.animation.play('idle');
            soundSprite.scrollFactor.set();
            soundSprite.antialiasing = FlxG.save.data.antialiasing;
            add(soundSprite);

            visibleShit = new FlxSpriteGroup();
            add(visibleShit);

            bg = new FlxSprite();
            bg.frames = Paths.getSparrowAtlas('menu/soundBg');
            bg.animation.addByPrefix('idle', 'soundBg', 12, true); //yes, its 12 fps, its intentional 
            bg.animation.play('idle');
            bg.scrollFactor.set();
            bg.antialiasing = FlxG.save.data.antialiasing;
            visibleShit.add(bg);
 
            antialiasing = FlxG.save.data.antialiasing;       
            scrollFactor.set();

            if (!flipped)
            {                             //x                                       //y
                soundSprite.setPosition(    5,                                      FlxG.height - soundSprite.width - 5);
                bg.setPosition(             soundSprite.x + soundSprite.width,      soundSprite.y - bg.height + 5);

                soundSprite.flipX = false;
                bg.flipX = false;
            }
            else
            {
                soundSprite.setPosition(    FlxG.width - soundSprite.width - 5,     FlxG.height - soundSprite.width - 5);
                bg.setPosition(             soundSprite.x - bg.width,      soundSprite.y - bg.height + 5);

                soundSprite.flipX = true;
                bg.flipX = true;
            }

            var offsetX:Int = (!flipped ? 40 : 70);

            sliders = new FlxTypedGroup<FlxUISlider>();

            for (i in 0...3)
            {
                var slider:FlxUISlider = new FlxUISlider(this, '', 0, 0, 0, 1, Std.int(bg.width * 0.75), 10, 20, FlxColor.BLACK, FlxColor.GRAY);
                slider.scrollFactor.set();
                slider.hoverSound = Paths.sound('scrollMenu', 'preload');
                slider.clickSound = Paths.sound('scrollMenu', 'preload');
                slider.setTexts("", false, null, null, 32);
                slider.hoverAlpha = 1;
                slider.nameLabel.offset.y = 10;
                slider.nameLabel.font = Paths.font('Crayawn-v58y.ttf');
                slider.valueLabel.visible = false;
                slider.valueLabel.alpha = 0;
                slider.minLabel.font = Paths.font('Crayawn-v58y.ttf');
                slider.maxLabel.font = Paths.font('Crayawn-v58y.ttf');
                slider.setPosition(bg.x + (bg.width / 2) - (slider.width / 4) - offsetX, bg.y + 30);
                slider.ID = i;
                visibleShit.add(slider);
                sliders.add(slider);
                add(slider);

                switch (i)
                {
                    case 0:
                        slider.varString = 'generalValue';
                        slider.value = FlxG.sound.volume;
                        slider.nameLabel.text = (FlxG.save.data.esp ? 'Volumen global' : 'Global volume');
                    case 1:
                        slider.y += slider.height / 1.5;
                        slider.varString = 'musicValue';
                        slider.value = FlxG.save.data.musicVolume;
                        slider.nameLabel.text = (FlxG.save.data.esp ? 'Volumen de la música' : 'Music volume');
                    case 2:
                        slider.y += (slider.height * 2) / 1.5;
                        slider.varString = 'soundValue';
                        slider.value = FlxG.save.data.soundVolume;
                        slider.nameLabel.text = (FlxG.save.data.esp ? 'Volumen del sonido' : 'Sound volume');
                }
            }
        }

    override function update(elapsed:Float)
    {
        if (this != null && FlxG.mouse != null)
        {
            //sound sprite alpha is lower when mouse overlaps it
            if (FlxG.mouse.overlaps(soundSprite))
                soundSprite.alpha = 0.8;
            else
                soundSprite.alpha = 1;

            //open the sound settings
            if (mouseOverlapsAndPressed(soundSprite, true))
                {
                    if (isActive)
                        CoolUtil.sound('cancelMenu', 'preload');
                    else
                        CoolUtil.sound('scrollMenu', 'preload');
        
                    isActive = !isActive;
                    
                    FlxG.save.flush();
                }

            //if clicked something else and is opened it closes
            if (mouseOverlapsAndPressed(soundSprite, false) && mouseOverlapsAndPressed(visibleShit, false) && isActive)
                {
                    isActive = false;
                    CoolUtil.sound('cancelMenu', 'preload');
                }
        }
        
        visibleShit.forEach(function(spr:FlxSprite)
        {
            spr.visible = isActive;
            spr.active = isActive;
        });

        if (isActive)
        {
            sliders.forEach(function(slider:FlxUISlider)
            {
                switch(slider.ID)
                {
                    case 0:
                        FlxG.sound.volume = generalValue;
                        generalValue = slider.value;
                    case 1:
                        FlxG.save.data.musicVolume = musicValue;
                        musicValue = slider.value;
                    case 2:
                        FlxG.save.data.soundVolume = soundValue;
                        soundValue = slider.value;
                }   
            });
        }
        
        super.update(elapsed);
    }

    //function to stop using FlxG.mouse.overlaps() && FlxG.mouse.justPressed
    function mouseOverlapsAndPressed(target:FlxBasic, doesItOverlap:Bool):Bool
    {
        if (doesItOverlap)
            return FlxG.mouse.overlaps(target) && FlxG.mouse.justPressed;
        else
            return !FlxG.mouse.overlaps(target) && FlxG.mouse.justPressed;
    }
}