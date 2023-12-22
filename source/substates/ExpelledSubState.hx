package substates;

import states.FreeplayState;
import states.PlayState;
import flixel.FlxG;

class ExpelledSubState extends flixel.FlxSubState
{
    private var versions:flixel.group.FlxGroup.FlxTypedGroup<flixel.text.FlxText>;
    private var curSelected:Int = 0;
    private var canDoSomething:Bool = true;

    public function new() super(0xC0000000);

	override public function create()
	{	
        FlxG.mouse.visible = true;

        var page = new flixel.FlxSprite().loadGraphic(Paths.image('menu/page', 'preload'));
        page.scrollFactor.set();
        page.screenCenter(X);
        page.y = -page.width;
        page.active = false;
        add(page);
        flixel.tweens.FlxTween.tween(page, {y: -430}, 1, {ease: flixel.tweens.FlxEase.sineOut});

        var erase = new flixel.text.FlxText(0, -page.width, 0, Language.get('FreeplayState', 'expelled_version_text'), 52);
		erase.scrollFactor.set();
		erase.color = flixel.util.FlxColor.BLACK;
        erase.font = Paths.font('Crayawn-v58y.ttf');
        erase.screenCenter(X);
        erase.active = false;
        add(erase);
        flixel.tweens.FlxTween.tween(erase, {y: -430 + 612}, 1, {ease: flixel.tweens.FlxEase.sineOut});

        add(versions = new flixel.group.FlxGroup.FlxTypedGroup<flixel.text.FlxText>());
        var xd = ['V1', 'V2', 'V3 (${Language.get('FreeplayState', 'official_text')})'];
        for (i in 0...xd.length)
        {
            var text = new flixel.text.FlxText(0, FlxG.height, FlxG.width, xd[i], 42);
            text.autoSize = false;
            text.setFormat(flixel.system.FlxAssets.FONT_DEFAULT, 42, flixel.util.FlxColor.WHITE, CENTER, OUTLINE, flixel.util.FlxColor.BLACK);
            text.scrollFactor.set();
            text.active = false;
            text.ID = i;
            versions.add(text);
            flixel.tweens.FlxTween.tween(text, {y: FlxG.height / 2 + (100 * i)}, 1, {ease: flixel.tweens.FlxEase.sineOut});
        }

		super.create();
	}

	override function update(elapsed:Float)
	{
        super.update(elapsed);

        if (!canDoSomething) return;

        versions.forEach(function (text)
        {
            if (CoolUtil.overlaps(text)) curSelected = text.ID;

            if (curSelected == text.ID) text.alpha = 0.5;
            else text.alpha = 1;
        });

        if (FlxG.mouse.overlaps(versions))
        {
            if (FlxG.mouse.justPressed && curSelected >= 0) //just in case
            {
                final official = 3;
                final isOfficial:Bool = (curSelected + 1) == official;
                final name = 'Expelled' + (isOfficial ? '' : ' V${curSelected + 1}');
                final daDiff:Int = (isOfficial ? FreeplayState.curDifficulty : 2);

                final songFormat = StringTools.replace(name, " ", "-");
			    PlayState.SONG = funkin.Song.loadFromJson(data.Highscore.formatSong(songFormat, daDiff), name);
			    PlayState.isStoryMode = false;
			    PlayState.storyDifficulty = daDiff;
			    PlayState.tries = 0;
                CoolUtil.sound('confirmMenu', 'preload');
                canDoSomething = false;
                new flixel.util.FlxTimer().start(0.5, function(_) substates.LoadingState.loadAndSwitchState(new PlayState()));
            }
        }
        else curSelected = -1;

        if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
        {
            CoolUtil.sound('cancelMenu', 'preload', 0.5);
            close();
        }
    }
}
