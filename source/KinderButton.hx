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

class KinderButton extends FlxSpriteGroup
{
    public var selected:Bool = false;
    public var daText:FlxText;
    public var texto:String = "";
    public var description:String;
    public var botton:FlxSprite;

    var colors = [0xA64D7B, 0x6DCCAF, 0xA17B55, 0x76DA9B, 0x7F8CDB, 0xC48CD9, 0xC4D88D, 0x685DD3];

    public function new(X:Float, Y:Float, texto:String = "", description:String)
        {
            super(X, Y);

            this.texto = texto;
            this.description = description;

            botton = new FlxSprite(X, Y);
            botton.loadGraphic(Paths.image('menu/button'));
            botton.color = colors[FlxG.random.int(0, 7)];
            botton.scrollFactor.set();
            botton.frameWidth = 1;
            botton.frameHeight = 1;
            botton.updateHitbox();
            add(botton);

            daText = new FlxText(X, Y, 0, "", 50);
            daText.setFormat(Paths.font('Crayawn-v58y.ttf'), 50, FlxColor.BLACK, CENTER);
            daText.text = texto;
            daText.scrollFactor.set();
            daText.x -= 20;
            daText.y += 25;
            daText.frameWidth = 1;
            daText.frameHeight = 1;
            daText.updateHitbox();
            add(daText);
 
            botton.antialiasing = FlxG.save.data.antialiasing;       
            daText.antialiasing = FlxG.save.data.antialiasing;     
            
            frameWidth = 200;
            frameHeight = 50;
            updateHitbox();

            x = X;
            y = Y;
        }

    override function update(elapsed:Float)
	{
        daText.text = texto;

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
            botton.alpha = 0.75;
        else
           botton.alpha = 1;
        
		super.update(elapsed);
    }
}