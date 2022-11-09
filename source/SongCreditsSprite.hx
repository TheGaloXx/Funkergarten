package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;

//i really like creating a new .hx for every fucking thing that i make

class SongCreditsSprite extends FlxSpriteGroup
{
    public var selected:Bool = false;
    public var daText:FlxText;
    public var author:String = "";
    public var description:String;
    public var botton:FlxSprite;

    public function new(Y:Float, song:String = "", author:String = "")
        {
            super(Y);

            this.author = author;

            botton = new FlxSprite();
            botton.loadGraphic(Paths.image('songCredit'));
            botton.scrollFactor.set();
            botton.screenCenter(X);
            botton.y = Y;
            add(botton);

            daText = new FlxText(0, Y, 0, "", 50);
            daText.setFormat(Paths.font('Crayawn-v58y.ttf'), 50, FlxColor.BLACK, CENTER);
            daText.text = song + "\n by " + author;
            daText.scrollFactor.set();
            daText.screenCenter(X);
            daText.y = Y;
            daText.y += 270;
            add(daText);
 
            botton.antialiasing = FlxG.save.data.antialiasing;       
            daText.antialiasing = FlxG.save.data.antialiasing;     

            scrollFactor.set();
            screenCenter(X);

            y = Y;
        }
}