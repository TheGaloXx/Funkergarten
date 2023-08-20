package data;

import flixel.FlxG;

class KeyBinds
{

    public static var gamepad:Bool = false;

    public static function resetBinds():Void{

        data.KadeEngineData.controls.data.upBind = "W";
        data.KadeEngineData.controls.data.downBind = "S";
        data.KadeEngineData.controls.data.leftBind = "A";
        data.KadeEngineData.controls.data.rightBind = "D";
        data.KadeEngineData.controls.data.killBind = "R";
        data.KadeEngineData.controls.data.gpupBind = "DPAD_UP";
        data.KadeEngineData.controls.data.gpdownBind = "DPAD_DOWN";
        data.KadeEngineData.controls.data.gpleftBind = "DPAD_LEFT";
        data.KadeEngineData.controls.data.gprightBind = "DPAD_RIGHT";
        data.PlayerSettings.player1.controls.loadKeyBinds();

	}

    public static function keyCheck():Void
    {
        if (data.KadeEngineData.controls.data.killBind == null)
        {
            data.KadeEngineData.controls.data.killBind = "R";
            trace("NO RESET");
        }
        if(data.KadeEngineData.controls.data.upBind == null){
            data.KadeEngineData.controls.data.upBind = "W";
            trace("No UP");
        }
        if (StringTools.contains(data.KadeEngineData.controls.data.upBind,"NUMPAD"))
            data.KadeEngineData.controls.data.upBind = "W";
        if(data.KadeEngineData.controls.data.downBind == null){
            data.KadeEngineData.controls.data.downBind = "S";
            trace("No DOWN");
        }
        if (StringTools.contains(data.KadeEngineData.controls.data.downBind,"NUMPAD"))
            data.KadeEngineData.controls.data.downBind = "S";
        if(data.KadeEngineData.controls.data.leftBind == null){
            data.KadeEngineData.controls.data.leftBind = "A";
            trace("No LEFT");
        }
        if (StringTools.contains(data.KadeEngineData.controls.data.leftBind,"NUMPAD"))
            data.KadeEngineData.controls.data.leftBind = "A";
        if(data.KadeEngineData.controls.data.rightBind == null){
            data.KadeEngineData.controls.data.rightBind = "D";
            trace("No RIGHT");
        }
        if (StringTools.contains(data.KadeEngineData.controls.data.rightBind,"NUMPAD"))
            data.KadeEngineData.controls.data.rightBind = "D";
        
        if(data.KadeEngineData.controls.data.gpupBind == null){
            data.KadeEngineData.controls.data.gpupBind = "DPAD_UP";
            trace("No GUP");
        }
        if(data.KadeEngineData.controls.data.gpdownBind == null){
            data.KadeEngineData.controls.data.gpdownBind = "DPAD_DOWN";
            trace("No GDOWN");
        }
        if(data.KadeEngineData.controls.data.gpleftBind == null){
            data.KadeEngineData.controls.data.gpleftBind = "DPAD_LEFT";
            trace("No GLEFT");
        }
        if(data.KadeEngineData.controls.data.gprightBind == null){
            data.KadeEngineData.controls.data.gprightBind = "DPAD_RIGHT";
            trace("No GRIGHT");
        }

        trace('KEYBINDS: ${data.KadeEngineData.controls.data.leftBind}-${data.KadeEngineData.controls.data.downBind}-${data.KadeEngineData.controls.data.upBind}-${data.KadeEngineData.controls.data.rightBind}.');
    }

}