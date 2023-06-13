package options;

import flixel.FlxG;

class OptionsMenuBase extends MusicBeatState
{
	public var canDoSomething:Bool = true;
	public var versionShit = new flixel.text.FlxText(5, FlxG.height + 40, FlxG.width, "", 12);
    public var state:flixel.FlxState;
    public var buttons = new flixel.group.FlxGroup.FlxTypedGroup<Objects.KinderButton>();

    override public function new(state:flixel.FlxState)
    {
        super();
        this.state = state;
    }
	override function create()
	{
		var time = Date.now().getHours();
		var bg = new flixel.FlxSprite().loadGraphic(Paths.image('menu/paper', 'preload'));
		bg.active = false;
		if (time > 19 || time < 8)
			bg.alpha = 0.7;
		add(bg);

        var paper = new flixel.FlxSprite().loadGraphic(Paths.image('menu/page', 'preload'));
        paper.screenCenter();
        paper.active = false;
        add(paper);

        add(buttons);

        var blackBorder = new flixel.FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 1500)), Std.int(versionShit.height + 600), flixel.util.FlxColor.BLACK);
		blackBorder.alpha = 0.8;
        blackBorder.active = false;
		add(blackBorder);

		versionShit.scrollFactor.set();
        versionShit.autoSize = false;
		versionShit.setFormat("VCR OSD Mono", 16, flixel.util.FlxColor.BLACK, LEFT, flixel.text.FlxText.FlxTextBorderStyle.OUTLINE, flixel.util.FlxColor.WHITE);
		versionShit.borderSize = 1.25;
        versionShit.active = false;
		add(versionShit);

		flixel.tweens.FlxTween.tween(versionShit,{y: FlxG.height - 18},2,{ease: flixel.tweens.FlxEase.elasticInOut});
		flixel.tweens.FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: flixel.tweens.FlxEase.elasticInOut});

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (canDoSomething)
            {
                if (controls.BACK)
                {
                    trace("backes in a epic way");
                    canDoSomething = false;

                    versionShit.text = "";

                    buttons.forEach(function(button)
                    {
                        button.active = false;
                    });
                                
                    KadeEngineData.flush(false);
                    MusicBeatState.switchState(state);
                }

                versionShit.text = Language.get('Global', 'options_idle');

                buttons.forEach(function(button)
                {
                    for (button in buttons)
                        if (button != null && button.selected) 
                            versionShit.text = button.description;
                });
            }
	}
}
