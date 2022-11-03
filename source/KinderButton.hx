package;

import flixel.ui.FlxButton;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;

//i really like creating a new .hx for every fucking thing that i make

class KinderButton extends FlxButton
{
    public var selected:Bool = false;
    public var daText:FlxText;
    public var texto:String = "";
    public var description:String;

    var colors = [0xffffff, 0xA64D7B, 0x6DCCAF, 0xA17B55, 0x76DA9B, 0x7F8CDB, 0xC48CD9, 0xC4D88D, 0x685DD3];

    public function new(x:Float, y:Float, text:String = "", description:String, ?OnClick:Void->Void)
        {
            super(x, y, OnClick);

            this.text = texto;
            this.description = description;

            loadGraphic(Paths.image('menu/button'));
            color = colors[FlxG.random.int(0, 8)];

            daText = new FlxText(0, 0, 0, "", 20);
            daText.setFormat(Paths.font('Crayawn-v58y.ttf'), 20, FlxColor.BLACK, CENTER);
            daText.text = text;
            add(daText);

            antialiasing = FlxG.save.data.antialiasing;

            
        }

    override function update(elapsed:Float)
	{
        if (FlxG.mouse != null)
            {
                if (this != null)
                    {
                        if (FlxG.mouse.overlaps(this))
                            {
                                selected = true;
                            }
                        else
                            selected = false;
                    }
            }

        if (selected)
            alpha = 0.5;
        else
            alpha = 1;
        
		super.update(elapsed);
    }

    function add(object:FlxBasic){}
}