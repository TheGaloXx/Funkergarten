package substates;

import flixel.tweens.FlxEase;
import objects.Objects.KinderButton;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class EraseData extends flixel.FlxSubState
{
    var page:FlxSprite;
    var erase:FlxText;
    var textLeft:FlxText;
    var textRight:FlxText;
    var areYouSure:Bool = false;

	override public function create()
	{	
        var bg2:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width), Std.int(FlxG.height), FlxColor.BLACK);
        bg2.alpha = 0;
        bg2.scrollFactor.set();
        bg2.screenCenter();
        bg2.active = false;
        add(bg2);
        FlxTween.tween(bg2, {alpha: 0.25}, 1);

        var bg:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 0.9), Std.int(FlxG.height * 0.9), FlxColor.BLACK);
        bg.alpha = 0;
        bg.scrollFactor.set();
        bg.screenCenter();
        bg.active = false;
        add(bg);
        FlxTween.tween(bg, {alpha: 0.75}, 1);

        page = new FlxSprite().loadGraphic(Paths.image('menu/page', 'preload'));
        page.scrollFactor.set();
        page.screenCenter(X);
        page.y = -page.width;
        page.active = false;
        add(page);
        FlxTween.tween(page, {y: -430}, 1, {ease: FlxEase.sineOut});

        erase = new FlxText(0, -page.width, 0, Language.get('EraseData', 'text_confirm'), 52);
		erase.scrollFactor.set();
		erase.color = FlxColor.BLACK;
        erase.font = Paths.font('Crayawn-v58y.ttf');
        erase.screenCenter(X);
        add(erase);

        textLeft = new FlxText(300, FlxG.height, 0, Language.get('EraseData', 'confirm'), 64);
        textLeft.setFormat(flixel.system.FlxAssets.FONT_DEFAULT, 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        textLeft.scrollFactor.set();
        add(textLeft);
        FlxTween.tween(textLeft, {y: FlxG.height / 2}, 1, {ease: FlxEase.sineOut});

        textRight = new FlxText(FlxG.width - 400, FlxG.height, 0, "No", 64);
        textRight.setFormat(flixel.system.FlxAssets.FONT_DEFAULT, 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        textRight.scrollFactor.set();
        add(textRight);
        FlxTween.tween(textRight, {y: FlxG.height / 2}, 1, {ease: FlxEase.sineOut});

		super.create();
	}

	override function update(elapsed:Float)
	{
        if (erase.y != ((page.y + page.width) - 200) && erase.active)
            erase.y = (page.y + page.width) - 200;
        else
            erase.active = false;

        if (CoolUtil.overlaps(textLeft)){
            textLeft.alpha = 0.5;
            textRight.alpha = 1;

            if (FlxG.mouse.justPressed)
            {
                if (!areYouSure)
                {
                    areYouSure = true;
                    setAlert();
                }
                else
                {
                    data.KadeEngineData.resetData();
                    close();
                }
            }
        }
        else if (CoolUtil.overlaps(textRight)){
            textLeft.alpha = 1;
            textRight.alpha = 0.5;

            if (FlxG.mouse.justPressed)
                close();
        }
        else
        {
            textLeft.alpha = 1;
            textRight.alpha = 1;
        }

        if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
            close();

        super.update(elapsed);
    }

    private function setAlert()
    {
        erase.visible = false;

        var black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        black.alpha = 0.75;
        black.scrollFactor.set();
        black.screenCenter();
        insert(members.indexOf(textLeft) - 1, black);

        var text:FlxText = new FlxText(0, 5, FlxG.width, Language.get('EraseData', 'warning'), 30);
        text.autoSize = false;
        text.setFormat(null, 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        text.borderSize = 6;
        text.borderQuality = 2;
        insert(members.indexOf(textLeft) - 1, text);
    }
}
