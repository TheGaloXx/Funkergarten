package states;

/// Code created by Rozebud for FPS Plus (thanks rozebud)
// modified by KadeDev for use in Kade Engine/Tricky

import options.GameplayOptions;
import flixel.FlxSubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import data.*;

using StringTools;

class KeyBindMenu extends FlxSubState
{
    private var canExit:Bool = false;

    private var tempKey:String = "";
    private var state:String = "select";

    private var curSelected:Int = 0;
    private var frames:Float = 0;

    private var blackBox:FlxSprite;
    private var keyTextDisplay:FlxText;
    private var keyWarning:FlxText;
    private var infoText:FlxText;

    private var warningTween:FlxTween;

    private var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    private final defaultKeys:Array<String> = ["A", "S", "W", "D", "R"];
    private var keys:Array<String> = 
    [
        KadeEngineData.controls.data.leftBind,
        KadeEngineData.controls.data.downBind,
        KadeEngineData.controls.data.upBind,
        KadeEngineData.controls.data.rightBind
    ];

	override function create()
	{
        GameplayOptions.instance.acceptInput = false;

        for (i in 0...keys.length)
        {
            if (keys[i] == null)
                keys[i] = defaultKeys[i];
        }

        addTexts();
        textUpdate();

		super.create();
	}

	override function update(elapsed:Float)
	{
        if (frames <= 0.5)
            frames += elapsed;

        switch(state)
        {
            case "select":
                if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)
                {
                    CoolUtil.sound('scrollMenu', 'preload', 0.5);
                    changeItem(-1);
                }

                if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN)
                {
                    CoolUtil.sound('scrollMenu', 'preload', 0.5);
                    changeItem(1);
                }

                if (FlxG.keys.justPressed.ENTER)
                {
                    CoolUtil.sound('scrollMenu', 'preload', 0.5);
                    state = "input";
                }
                else if (FlxG.keys.justPressed.ESCAPE)
                {
                    quit();
                }
                else if (FlxG.keys.justPressed.BACKSPACE)
                {
                    reset();
                }

            case "input":
                tempKey = keys[curSelected];
                keys[curSelected] = "?";

                textUpdate();
                state = "waiting";

            case "waiting":
                    if (FlxG.keys.justPressed.ESCAPE)
                    {
                        keys[curSelected] = tempKey;
                        state = "select";
                        CoolUtil.sound('confirmMenu', 'preload');
                    }
                    else if (FlxG.keys.justPressed.ENTER)
                    {
                        addKey(defaultKeys[curSelected]);
                        save();
                        state = "select";
                    }
                    else if (FlxG.keys.justPressed.ANY)
                    {
                        addKey(FlxG.keys.getIsDown()[0].ID.toString());
                        save();
                        state = "select";
                    }
            case "exiting":
            default: state = "select";
        }

        if(FlxG.keys.justPressed.ANY)
			textUpdate();

		super.update(elapsed);
	}

    private inline function textUpdate()
    {
        keyTextDisplay.text = "\n\n";

        for (i in 0...4)
        {
            final textStart = (i == curSelected) ? ">  " : "  ";
            keyTextDisplay.text += textStart + keyText[i] + ":  " + ((keys[i] != keyText[i]) ? (keys[i] + "  /  ") : "" ) + keyText[i] + " ARROW\n\n";
        }
    }

    private function save()
    {
        KadeEngineData.controls.data.upBind = keys[2];
        KadeEngineData.controls.data.downBind = keys[1];
        KadeEngineData.controls.data.leftBind = keys[0];
        KadeEngineData.controls.data.rightBind = keys[3];

        KadeEngineData.flush();
        PlayerSettings.player1.controls.loadKeyBinds();
    }

    private function reset()
    {
        for(i in 0...5)
            keys[i] = defaultKeys[i];

        quit();
    }

    private function quit()
    {
        if (!canExit)
            return;

        canExit = false;

        state = "exiting";
        save();

        GameplayOptions.instance.acceptInput = true;

        FlxTween.tween(blackBox, {alpha: 0}, 0.75, {ease: FlxEase.expoInOut, onComplete: function(_) close()});
        FlxTween.tween(keyTextDisplay, {alpha: 0}, 0.65, {ease: FlxEase.expoInOut});
        FlxTween.tween(infoText, {alpha: 0}, 0.65, {ease: FlxEase.expoInOut});
    }

	function addKey(r:String)
    {
        var shouldReturn:Bool = true;
        var notAllowed:Array<String> = [];

        for (x in ["ESCAPE", "ENTER", "BACKSPACE", "SPACE", "TAB"])
            notAllowed.push(x);

        trace(notAllowed);

        for (x in 0...keys.length)
        {
            var oK = keys[x];

            if(oK == r)
                keys[x] = null;

            if (notAllowed.contains(oK))
            {
                keys[x] = null;
                return;
            }
        }

        if (r.contains("NUMPAD"))
        {
            keys[curSelected] = null;
            return;
        }

        if (shouldReturn)
        {
            keys[curSelected] = r;
            CoolUtil.sound('scrollMenu', 'preload', 0.5);
        }
        else
        {
            keys[curSelected] = tempKey;
            CoolUtil.sound('scrollMenu', 'preload', 0.5);
            keyWarning.alpha = 1;
            warningTween.cancel();
            warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 2});
        }
	}

    private inline function changeItem(_amount:Int = 0)
    {
        curSelected += _amount;

        if (curSelected > 3)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = 3;
    }

    private function addTexts():Void
    {
        blackBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        blackBox.scrollFactor.set();
        blackBox.scale.set(FlxG.width, FlxG.height);
        blackBox.updateHitbox();
        blackBox.active = false;
        blackBox.alpha = 0;
        add(blackBox);

        keyTextDisplay = new FlxText(0, 50, FlxG.width, "", 72);
		keyTextDisplay.scrollFactor.set();
        keyTextDisplay.autoSize = false;
		keyTextDisplay.setFormat(Paths.font('Crayawn-v58y.ttf'), 68, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 4;
        keyTextDisplay.alpha = 0;
        keyTextDisplay.active = false;
        add(keyTextDisplay);

        infoText = new FlxText(0, 620, FlxG.width, Language.get('Keybinds', 'info'), 72);
		infoText.scrollFactor.set();
        infoText.autoSize = false;
		infoText.setFormat(Paths.font('Crayawn-v58y.ttf'), 48, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 2;
        infoText.active = false;
        infoText.alpha = 0;
        add(infoText);

        FlxTween.tween(blackBox, {alpha: 0.85}, 0.8, {ease: FlxEase.expoInOut});
        FlxTween.tween(keyTextDisplay, {alpha: 1}, 0.8, {ease: FlxEase.expoInOut});
        FlxTween.tween(infoText, {alpha: 1}, 1.2, {ease: FlxEase.expoInOut, onComplete: function(_) canExit = true});
    }
}
