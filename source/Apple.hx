package;

import flixel.FlxG;
import flixel.FlxSprite;

class Apple extends FlxSprite
{
    override public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic(Paths.image('gameplay/apple'));

        setGraphicSize(Std.int(width * 0.6));
        antialiasing = FlxG.save.data.antialiasing;
        updateHitbox();
        scrollFactor.set();
    }
}