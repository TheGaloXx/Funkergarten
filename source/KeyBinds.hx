import flixel.FlxG;

class KeyBinds
{

    public static var gamepad:Bool = false;

    public static function resetBinds():Void{

        KadeEngineData.controls.data.upBind = "W";
        KadeEngineData.controls.data.downBind = "S";
        KadeEngineData.controls.data.leftBind = "A";
        KadeEngineData.controls.data.rightBind = "D";
        KadeEngineData.controls.data.killBind = "R";
        KadeEngineData.controls.data.gpupBind = "DPAD_UP";
        KadeEngineData.controls.data.gpdownBind = "DPAD_DOWN";
        KadeEngineData.controls.data.gpleftBind = "DPAD_LEFT";
        KadeEngineData.controls.data.gprightBind = "DPAD_RIGHT";
        PlayerSettings.player1.controls.loadKeyBinds();

	}

    public static function keyCheck():Void
    {
        if (KadeEngineData.controls.data.killBind == null)
        {
            KadeEngineData.controls.data.killBind = "R";
            trace("NO RESET");
        }
        if(KadeEngineData.controls.data.upBind == null){
            KadeEngineData.controls.data.upBind = "W";
            trace("No UP");
        }
        if (StringTools.contains(KadeEngineData.controls.data.upBind,"NUMPAD"))
            KadeEngineData.controls.data.upBind = "W";
        if(KadeEngineData.controls.data.downBind == null){
            KadeEngineData.controls.data.downBind = "S";
            trace("No DOWN");
        }
        if (StringTools.contains(KadeEngineData.controls.data.downBind,"NUMPAD"))
            KadeEngineData.controls.data.downBind = "S";
        if(KadeEngineData.controls.data.leftBind == null){
            KadeEngineData.controls.data.leftBind = "A";
            trace("No LEFT");
        }
        if (StringTools.contains(KadeEngineData.controls.data.leftBind,"NUMPAD"))
            KadeEngineData.controls.data.leftBind = "A";
        if(KadeEngineData.controls.data.rightBind == null){
            KadeEngineData.controls.data.rightBind = "D";
            trace("No RIGHT");
        }
        if (StringTools.contains(KadeEngineData.controls.data.rightBind,"NUMPAD"))
            KadeEngineData.controls.data.rightBind = "D";
        
        if(KadeEngineData.controls.data.gpupBind == null){
            KadeEngineData.controls.data.gpupBind = "DPAD_UP";
            trace("No GUP");
        }
        if(KadeEngineData.controls.data.gpdownBind == null){
            KadeEngineData.controls.data.gpdownBind = "DPAD_DOWN";
            trace("No GDOWN");
        }
        if(KadeEngineData.controls.data.gpleftBind == null){
            KadeEngineData.controls.data.gpleftBind = "DPAD_LEFT";
            trace("No GLEFT");
        }
        if(KadeEngineData.controls.data.gprightBind == null){
            KadeEngineData.controls.data.gprightBind = "DPAD_RIGHT";
            trace("No GRIGHT");
        }

        trace('KEYBINDS: ${KadeEngineData.controls.data.leftBind}-${KadeEngineData.controls.data.downBind}-${KadeEngineData.controls.data.upBind}-${KadeEngineData.controls.data.rightBind}.');
    }

}