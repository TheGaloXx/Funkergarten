package data;

class KeyBinds
{

    public static var gamepad:Bool = false;

    public static function resetBinds():Void
    {
        KadeEngineData.controls.data.upBind = "W";
        KadeEngineData.controls.data.downBind = "S";
        KadeEngineData.controls.data.leftBind = "A";
        KadeEngineData.controls.data.rightBind = "D";
        KadeEngineData.controls.data.killBind = "R";
        KadeEngineData.controls.data.gpupBind = "DPAD_UP";
        KadeEngineData.controls.data.gpdownBind = "DPAD_DOWN";
        KadeEngineData.controls.data.gpleftBind = "DPAD_LEFT";
        KadeEngineData.controls.data.gprightBind = "DPAD_RIGHT";

        data.PlayerSettings.player1.controls.loadKeyBinds();
	}

    public static function keyCheck():Void
    {
        KadeEngineData.controls.data.killBind ??= "R";
        KadeEngineData.controls.data.upBind ??= "W";

        if (StringTools.contains(KadeEngineData.controls.data.upBind, "NUMPAD"))
            KadeEngineData.controls.data.upBind = "W";

        KadeEngineData.controls.data.downBind ??= "S";
    
        if (StringTools.contains(KadeEngineData.controls.data.downBind, "NUMPAD"))
            KadeEngineData.controls.data.downBind = "S";

        KadeEngineData.controls.data.leftBind ??= "A";

        if (StringTools.contains(KadeEngineData.controls.data.leftBind, "NUMPAD"))
            KadeEngineData.controls.data.leftBind = "A";

        KadeEngineData.controls.data.rightBind ??= "D";

        if (StringTools.contains(KadeEngineData.controls.data.rightBind, "NUMPAD"))
            KadeEngineData.controls.data.rightBind = "D";
        
        KadeEngineData.controls.data.gpupBind ??= "DPAD_UP";
        KadeEngineData.controls.data.gpdownBind ??= "DPAD_DOWN";
        KadeEngineData.controls.data.gpleftBind ??= "DPAD_LEFT";
        KadeEngineData.controls.data.gprightBind ??= "DPAD_RIGHT";

        trace('KEYBINDS: [${KadeEngineData.controls.data.leftBind} - ${KadeEngineData.controls.data.downBind} - ${KadeEngineData.controls.data.upBind} - ${KadeEngineData.controls.data.rightBind}].');
    }

}