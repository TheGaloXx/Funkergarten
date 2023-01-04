package substates;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import Objects.KinderButton;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;

class EraseData extends FlxSubState
{
    var bg2:FlxSprite;
    var bg:FlxSprite;
    var page:FlxSprite;
    var erase:FlxText;
    var ye:KinderButton;
    var no:KinderButton;

	override function create()
	{	
        FlxG.mouse.visible = true;

        bg2 = new FlxSprite().makeGraphic(Std.int(FlxG.width), Std.int(FlxG.height), FlxColor.BLACK);
        bg2.alpha = 0;
        bg2.scrollFactor.set();
        bg2.screenCenter();
        add(bg2);
        FlxTween.tween(bg2, {alpha: 0.25}, 1);

        bg = new FlxSprite().makeGraphic(Std.int(FlxG.width * 0.9), Std.int(FlxG.height * 0.9), FlxColor.BLACK);
        bg.alpha = 0;
        bg.scrollFactor.set();
        bg.screenCenter();
        add(bg);
        FlxTween.tween(bg, {alpha: 0.75}, 1);

        page = new FlxSprite().loadGraphic(Paths.image('menu/page'));
        page.antialiasing = FlxG.save.data.antialiasing;
        page.scrollFactor.set();
        page.screenCenter(X);
        page.y -= page.width;
        add(page);
        FlxTween.tween(page, {y: -430}, 1, {ease: FlxEase.sineOut});

        erase = new FlxText(0, 0, 0, (FlxG.save.data.esp ? "¿Quieres borrar los datos y guardados actuales?" : "Do you want to erase the saved data?"), 52);
		erase.scrollFactor.set();
		erase.color = FlxColor.BLACK;
        erase.font = Paths.font('Crayawn-v58y.ttf');
        erase.screenCenter(X);
        add(erase);

		super.create();
	}

	override function update(elapsed:Float)
	{
        if (erase != null && page != null){
            erase.y = (page.y + page.width) - 200;
            erase.screenCenter(X);
        }

        if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
            close();



        super.update(elapsed);
    }
}
