package substates;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.FlxG;

class LockedSongSubstate extends FlxSubState
{
    private var song:String;

    public function new(song:String)
    {
        super(0xE1000000);

        this.song = StringTools.replace(CoolUtil.normalize(song), '-', '_');
    }

	override public function create()
	{
		super.create();

        var title:String = Language.get('Locked_Songs', '${song}_text');
        title ??= Language.get('Locked_Songs', 'other_text');

        var advice = new FlxText(0, 0, FlxG.width, title, 60);
		advice.scrollFactor.set();
        advice.autoSize = false;
        advice.alignment = CENTER;
        advice.font = Paths.font('Crayawn-v58y.ttf');
        advice.active = false;
        advice.screenCenter(Y);
        advice.scale.set(1.1, 1.1);
        add(advice);

        FlxTween.tween(advice.scale, {x: 1, y: 1}, 0.5, {ease: FlxEase.sineOut});
	}

	override function update(elapsed:Float)
	{
        // super.update(elapsed);

        if (FlxG.keys.anyJustPressed([ENTER, BACKSPACE, ESCAPE, SPACE]) || FlxG.mouse.justPressed || FlxG.mouse.justPressedMiddle || FlxG.mouse.justPressedRight)
        {
            CoolUtil.sound('cancelMenu', 'preload', 0.5);
            close();
        }
    }
}
