package;

import flixel.util.FlxColor;
import flixel.text.FlxText;

class NoteCombo extends FlxText
{
    public var selected:Bool = false;

    public function new()
        {
            super();

            alignment = CENTER;
            color = FlxColor.BLACK;
            borderSize = 2;
            size = 125;
            font = Paths.font("againts.otf");
            antialiasing = true;
            scrollFactor.set();
            screenCenter();
            x = x - 450;
            borderColor = FlxColor.WHITE;
            borderStyle = OUTLINE;
        }
}