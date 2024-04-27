package objects;

import options.OptionsMenu;
import flixel.input.mouse.FlxMouseEvent;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;

class KinderButton extends FlxSpriteGroup
{
    public var callback:Void->Void;
    public var text(default, set):String = "";
    public var description:String;

    private var actualColor:FlxColor;
    private var daText:FlxText;
    private var button:FlxSprite;
    private var selected(default, set):Bool;

    public function new(X:Float, Y:Float, text:String, alphaChange:Bool = true)
    {
        super(X, Y);

        button = new FlxSprite();
        button.loadGraphic(Paths.image('menu/' + (alphaChange ? 'button' : 'solidButton'), 'preload'));
        button.color = FlxG.random.getObject([0xA64D7B, 0x6DCCAF, 0xA17B55, 0x76DA9B, 0x7F8CDB, 0xC48CD9, 0xC4D88D, 0x685DD3]);
        button.scrollFactor.set();
        add(button);

        actualColor = button.color;

        daText = new FlxText(0, 0, button.width - 10, '', 50);
        daText.autoSize = false;
        daText.setFormat(Paths.font('Crayawn-v58y.ttf'), 50, FlxColor.BLACK, CENTER);
        daText.scrollFactor.set();
        add(daText);

        scrollFactor.set();

        this.text = text;

        FlxMouseEvent.add(button, onClick, null, onOverlap, onNotOverlap, false, true, false);
    }

    override function update(elapsed:Float)
	{
		// super.update(elapsed);
    }

	private function set_text(value:String):String
    {
        text = value;

        daText.text = value;
        daText.y = button.y + (button.height - daText.height) / 2;

        return text;
	}

    private function onClick(spr:FlxSprite):Void
    {
        if (!active)
            return;

        callback();

        CoolUtil.sound('scrollMenu', 'preload', 0.4);
    }

    private function onOverlap(spr:FlxSprite):Void
    {
        if (!active)
            return;

        if (!selected)
        {
            if (description != null && description.length > 0)
            {
                OptionsMenu.instance.text.setDescription(description);
            }

            CoolUtil.sound('scrollMenu', 'preload', 0.4);
            selected = true;
        }
    }

    private function onNotOverlap(spr:FlxSprite):Void
    {
        if (!active)
            return;

        if (selected && description != null && description.length > 0)
        {
            OptionsMenu.instance.text.setDescription();
        }

        selected = false;
    }

    override function destroy():Void
    {
        FlxMouseEvent.remove(button);

        super.destroy();
    }

    function set_selected(value:Bool):Bool
    {
        selected = value;

        button.color = (selected) ? FlxColor.YELLOW : actualColor;

        return selected;
    }

    public function setup(X:Float, Y:Float, newText:String):Void
    {
        setPosition(X, Y);

        button.color = FlxG.random.getObject([0xA64D7B, 0x6DCCAF, 0xA17B55, 0x76DA9B, 0x7F8CDB, 0xC48CD9, 0xC4D88D, 0x685DD3]);
        actualColor = button.color;
        
        text = newText;
    }
}