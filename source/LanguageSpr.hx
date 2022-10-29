package;

import flixel.FlxG;
import flixel.FlxSprite;

//i really like creating a new .hx for every fucking thing that i make

class LanguageSpr extends FlxSprite
{
    public var selected:Bool = false;

    public function new(x:Float, y:Float, idiom:String)
        {
            super(x, y, idiom);

            switch(idiom)
            {
                case 'english':
                    loadGraphic(Paths.image('menu/Eng'));
                case 'español':
                    loadGraphic(Paths.image('menu/Esp'));
            }

            antialiasing = FlxG.save.data.antialiasing;
        }

    override function update(elapsed:Float)
	{
        if (selected)
            alpha = 1;
        else
            alpha = 0.5;
        
		super.update(elapsed);
    }
}