package data;

class KeyBinds
{
    public static function resetBinds():Void
    {
        KadeEngineData.controls.data.upBind = "W";
        KadeEngineData.controls.data.downBind = "S";
        KadeEngineData.controls.data.leftBind = "A";
        KadeEngineData.controls.data.rightBind = "D";
        KadeEngineData.controls.data.killBind = "R";

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

        trace('KEYBINDS: [${KadeEngineData.controls.data.leftBind} - ${KadeEngineData.controls.data.downBind} - ${KadeEngineData.controls.data.upBind} - ${KadeEngineData.controls.data.rightBind}].');
    }

}