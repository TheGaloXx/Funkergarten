package options;

import funkin.MusicBeatState;
import data.GlobalData;
import flixel.FlxState;
import objects.Objects.KinderButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

class OptionsMenuBase extends MusicBeatState
{
	public var canDoSomething:Bool = true;
    public var state:FlxState;
    public var buttons:FlxTypedGroup<KinderButton>;
    public var stuff:Map<String, Float> = 
    [
        "i" => -1,
        "x" => 357,
        "y" => 0
    ];

    override public function new(state:FlxState)
    {
        super();

        this.state = state;
    }

	override function create()
	{
		final time = Date.now().getHours();

		var bg = new FlxSprite();
        bg.frames = Paths.getSparrowAtlas('menu/credits_assets', 'preload');
		bg.animation.addByPrefix('idle', 'paper', 0, false);
		bg.animation.play('idle');
		bg.active = false;
		add(bg);

        if (time > 19 || time < 8)
			bg.alpha = 0.7;

        var paper = new FlxSprite().loadGraphic(Paths.image('menu/page', 'preload'));
        paper.screenCenter();
        paper.active = false;
        add(paper);

        buttons = new FlxTypedGroup<KinderButton>();
        add(buttons);

        addButtons();

		super.create();
	}

	override function update(elapsed:Float)
	{
        if (!canDoSomething)
            return;

		super.update(elapsed);

        if (controls.BACK)
        {
            CoolUtil.sound('cancelMenu', 'preload', 0.5);
            trace("backes in a epic way");

            canDoSomething = false;
            buttons.active = false;
                
            GlobalData.flush();
            MusicBeatState.switchState(state);
        }
	}

    private inline function addButton(text:String):KinderButton
    {       
        stuff.set("i", stuff.get("i") + 1);

        if (stuff.get("i") % 2 == 0)
        {
            stuff.set("y", stuff.get("y") + 80);
        }

        if (stuff.get("x") == 357)
        {
            stuff.set("x", 157);
        }
        else
        {
            stuff.set("x", 357);
        }

        var button = new KinderButton(stuff.get('x'), stuff.get('y'), text, null);
        buttons.add(button);

        return button;
    }

    // just to override lol
    private function addButtons():Void {}

    private inline function data():Dynamic
    {
        return GlobalData.settings;
    }
}
