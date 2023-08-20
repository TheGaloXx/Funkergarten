package states;

/// Code created by Rozebud for FPS Plus (thanks rozebud)
// modified by KadeDev for use in Kade Engine/Tricky

import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;


using StringTools;

class KeyBindMenu extends FlxSubState
{

    var keyTextDisplay:FlxText;
    var keyWarning:FlxText;
    var warningTween:FlxTween;
    var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    var defaultKeys:Array<String> = ["A", "S", "W", "D", "R"];
    var defaultGpKeys:Array<String> = ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "DPAD_RIGHT"];
    var curSelected:Int = 0;

    var keys:Array<String> = [data.KadeEngineData.controls.data.leftBind,
                                data.KadeEngineData.controls.data.downBind,
                                data.KadeEngineData.controls.data.upBind,
                                data.KadeEngineData.controls.data.rightBind];
    var gpKeys:Array<String> = [data.KadeEngineData.controls.data.gpleftBind,
                                data.KadeEngineData.controls.data.gpdownBind,
                                data.KadeEngineData.controls.data.gpupBind,
                                data.KadeEngineData.controls.data.gprightBind];
    var tempKey:String = "";
    var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "SPACE", "TAB"];

    var blackBox:FlxSprite;
    var infoText:FlxText;

    var state:String = "select";

	override function create()
	{	
        for (i in 0...keys.length)
        {
            var k = keys[i];
            if (k == null)
                keys[i] = defaultKeys[i];
        }

        for (i in 0...gpKeys.length)
        {
            var k = gpKeys[i];
            if (k == null)
                gpKeys[i] = defaultGpKeys[i];
        }

        keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat("VCR OSD Mono", 42, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 2;
		keyTextDisplay.borderQuality = 3;

        blackBox = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        add(blackBox);

        infoText = new FlxText(-10, 580, 1280, 'Current Mode: ${data.KeyBinds.gamepad ? 'GAMEPAD' : 'KEYBOARD'}. Press TAB to switch\n(${data.KeyBinds.gamepad ? 'RIGHT Trigger' : 'Escape'} to save, ${data.KeyBinds.gamepad ? 'LEFT Trigger' : 'Backspace'} to leave without saving. ${data.KeyBinds.gamepad ? 'START To change a keybind' : ''})', 72);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 2;
		infoText.borderQuality = 3;
        infoText.alpha = 0;
        infoText.screenCenter(FlxAxes.X);
        add(infoText);
        add(keyTextDisplay);

        blackBox.alpha = 0;
        keyTextDisplay.alpha = 0;

        FlxTween.tween(keyTextDisplay, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
        FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
        FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});

        options.ImportantOptions.instance.acceptInput = false;

        textUpdate();

		super.create();
	}

    var frames = 0;

	override function update(elapsed:Float)
	{
        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

        if (frames <= 10)
            frames++;

        switch(state){

            case "select":
                if (FlxG.keys.justPressed.UP)
                {
                    CoolUtil.sound('scrollMenu', 'preload');
                    changeItem(-1);
                }

                if (FlxG.keys.justPressed.DOWN)
                {
                    CoolUtil.sound('scrollMenu', 'preload');
                    changeItem(1);
                }

                if (FlxG.keys.justPressed.TAB)
                {
                    data.KeyBinds.gamepad = !data.KeyBinds.gamepad;
                    infoText.text = 'Current Mode: ${data.KeyBinds.gamepad ? 'GAMEPAD' : 'KEYBOARD'}. Press TAB to switch\n(${data.KeyBinds.gamepad ? 'RIGHT Trigger' : 'Escape'} to save, ${data.KeyBinds.gamepad ? 'LEFT Trigger' : 'Backspace'} to leave without saving. ${data.KeyBinds.gamepad ? 'START To change a keybind' : ''})';
                    textUpdate();
                }

                if (FlxG.keys.justPressed.ENTER){
                    CoolUtil.sound('scrollMenu', 'preload');
                    state = "input";
                }
                else if(FlxG.keys.justPressed.ESCAPE){
                    quit();
                }
                else if (FlxG.keys.justPressed.BACKSPACE){
                    reset();
                }
                if (gamepad != null) // GP Logic
                {
                    if (gamepad.justPressed.DPAD_UP)
                    {
                        CoolUtil.sound('scrollMenu', 'preload');
                        changeItem(-1);
                        textUpdate();
                    }
                    if (gamepad.justPressed.DPAD_DOWN)
                    {
                        CoolUtil.sound('scrollMenu', 'preload');
                        changeItem(1);
                        textUpdate();
                    }

                    if (gamepad.justPressed.START && frames > 10){
                        CoolUtil.sound('scrollMenu', 'preload');
                        state = "input";
                    }
                    else if(gamepad.justPressed.LEFT_TRIGGER){
                        quit();
                    }
                    else if (gamepad.justPressed.RIGHT_TRIGGER){
                        reset();
                    }
                }

            case "input":
                tempKey = keys[curSelected];
                keys[curSelected] = "?";
                if (data.KeyBinds.gamepad)
                    gpKeys[curSelected] = "?";
                textUpdate();
                state = "waiting";

            case "waiting":
                if (gamepad != null && data.KeyBinds.gamepad) // GP Logic
                {
                    if(FlxG.keys.justPressed.ESCAPE){ // just in case you get stuck
                        gpKeys[curSelected] = tempKey;
                        state = "select";
                        CoolUtil.sound('confirmMenu', 'preload');
                    }

                    if (gamepad.justPressed.START)
                    {
                        addKeyGamepad(defaultKeys[curSelected]);
                        save();
                        state = "select";
                    }

                    if (gamepad.justPressed.ANY)
                    {
                        trace(gamepad.firstJustPressedID());
                        addKeyGamepad(gamepad.firstJustPressedID());
                        save();
                        state = "select";
                        textUpdate();
                    }

                }
                else
                {
                    if(FlxG.keys.justPressed.ESCAPE){
                        keys[curSelected] = tempKey;
                        state = "select";
                        CoolUtil.sound('confirmMenu', 'preload');
                    }
                    else if(FlxG.keys.justPressed.ENTER){
                        addKey(defaultKeys[curSelected]);
                        save();
                        state = "select";
                    }
                    else if(FlxG.keys.justPressed.ANY){
                        addKey(FlxG.keys.getIsDown()[0].ID.toString());
                        save();
                        state = "select";
                    }
                }


            case "exiting":


            default:
                state = "select";

        }

        if(FlxG.keys.justPressed.ANY)
			textUpdate();

		super.update(elapsed);
		
	}

    function textUpdate(){

        keyTextDisplay.text = "\n\n";

        if (data.KeyBinds.gamepad)
        {
            for(i in 0...4){

                var textStart = (i == curSelected) ? "> " : "  ";
                trace(gpKeys[i]);
                keyTextDisplay.text += textStart + keyText[i] + ": " + gpKeys[i] + "\n";
                
            }
        }
        else
        {
            for(i in 0...4){

                var textStart = (i == curSelected) ? "> " : "  ";
                keyTextDisplay.text += textStart + keyText[i] + ": " + ((keys[i] != keyText[i]) ? (keys[i] + " / ") : "" ) + keyText[i] + " ARROW\n";

            }
        }

        keyTextDisplay.screenCenter();

    }

    function save(){

        data.KadeEngineData.controls.data.upBind = keys[2];
        data.KadeEngineData.controls.data.downBind = keys[1];
        data.KadeEngineData.controls.data.leftBind = keys[0];
        data.KadeEngineData.controls.data.rightBind = keys[3];
        
        data.KadeEngineData.controls.data.gpupBind = gpKeys[2];
        data.KadeEngineData.controls.data.gpdownBind = gpKeys[1];
        data.KadeEngineData.controls.data.gpleftBind = gpKeys[0];
        data.KadeEngineData.controls.data.gprightBind = gpKeys[3];

        data.KadeEngineData.flush();

        data.PlayerSettings.player1.controls.loadKeyBinds();

    }

    function reset(){

        for(i in 0...5){
            keys[i] = defaultKeys[i];
        }
        quit();

    }

    function quit(){

        state = "exiting";

        save();

        options.ImportantOptions.instance.acceptInput = true;

        FlxTween.tween(keyTextDisplay, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
        FlxTween.tween(blackBox, {alpha: 0}, 1.1, {ease: FlxEase.expoInOut, onComplete: function(flx:FlxTween)
            {
                close();
            }});
        FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
    }


    function addKeyGamepad(r:String){

        var shouldReturn:Bool = true;

        var notAllowed:Array<String> = ["START", "RIGHT_TRIGGER", "LEFT_TRIGGER"];

        for(x in 0...gpKeys.length)
            {
                var oK = gpKeys[x];
                if(oK == r)
                    gpKeys[x] = null;
                if (notAllowed.contains(oK))
                {
                    gpKeys[x] = null;
                    return;
                }
            }

        if(shouldReturn){
            gpKeys[curSelected] = r;
            CoolUtil.sound('scrollMenu', 'preload');
        }
        else{
            gpKeys[curSelected] = tempKey;
            CoolUtil.sound('scrollMenu', 'preload');
            keyWarning.alpha = 1;
            warningTween.cancel();
            warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 2});
        }

	}

	function addKey(r:String){

        var shouldReturn:Bool = true;

        var notAllowed:Array<String> = [];

        for(x in blacklist){notAllowed.push(x);}

        trace(notAllowed);

        for(x in 0...keys.length)
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

        if(shouldReturn){
            keys[curSelected] = r;
            CoolUtil.sound('scrollMenu', 'preload');
        }
        else{
            keys[curSelected] = tempKey;
            CoolUtil.sound('scrollMenu', 'preload');
            keyWarning.alpha = 1;
            warningTween.cancel();
            warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 2});
        }

	}

    function changeItem(_amount:Int = 0)
    {
        curSelected += _amount;
                
        if (curSelected > 3)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = 3;
    }
}
