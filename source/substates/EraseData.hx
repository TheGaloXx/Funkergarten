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

	public function new()
	{	
        super();
        
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

        no = new KinderButton(FlxG.width - 200, 600, "No", "", function()    
        {
            close();
        }, false);
        trace("Added no: " + no.exists + no.active + no.isOnScreen() + no.getPosition() + no.getScreenPosition() + no.visible + no.alpha);
        add(no);
        trace("Added no: " + no.exists + no.active + no.isOnScreen() + no.getPosition() + no.getScreenPosition() + no.visible + no.alpha);
        //FlxTween.tween(no, {y: 600}, 1, {ease: FlxEase.sineOut});

        ye = new KinderButton(200, 600, (FlxG.save.data.esp ? "Si" : "Yes"), "", function()    
        {
            ye.active = false;
            no.active = false;

            var black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
            black.alpha = 0.75;
            black.scrollFactor.set();
            black.screenCenter();
            add(black);
            //FlxTween.tween(black, {alpha: 0.75}, 0.5);

            var epicText:String = (FlxG.save.data.esp ?
            "ALERTA:\nEsto borrará todos los datos guardados relacionados con canciones desbloqueadas y otros eventos, ¿está seguro de que desea borrarlos?\n(NOTA: esto NO borrará los datos relacionados con la configuración de opciones, como la combinación de teclas u otras preferencias)"

            :

            "ALERT:\nThis will clear all saved data related to unlocked songs and other events, are you sure you want to erase it?\n(NOTE: This will NOT clear data related to options settings such as keybinds or other preferences)");

            var text:FlxText = new FlxText(0, 0, FlxG.width, epicText, 160);
            text.setFormat(null, 160, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
            text.borderSize = 6;
            text.borderQuality = 2;
            add(text);

            var uSure:KinderButton = new KinderButton(200, FlxG.height - 200, (FlxG.save.data.esp ? "Si" : "Yes"), "", function()
            {
                KadeEngineData.resetData();
                close();
            });
            add(uSure);

            var uSurent:KinderButton = new KinderButton(FlxG.width - 200, FlxG.height - 200, "No", "", function()
                {
                    close();
                });
            add(uSurent);
        });
        trace("Added ye: " + ye.exists + ye.active + ye.isOnScreen() + ye.getPosition() + ye.getScreenPosition() + ye.visible + ye.alpha);
        add(ye);
        trace("Added ye: " + ye.exists + ye.active + ye.isOnScreen() + ye.getPosition() + ye.getScreenPosition() + ye.visible + ye.alpha);
        //FlxTween.tween(ye, {y: 600}, 1, {ease: FlxEase.sineOut});

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
