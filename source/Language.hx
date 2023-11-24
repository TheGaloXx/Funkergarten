package;

/* sanco here, 
    i thought on doing it my way (https://github.com/SanicBTW/Just-Another-FNF-Engine/blob/221672cfcc8e77ab1db4b5a11e23b14e642425a2/source/base/system/Language.hx)
    but i thought it was going to be hard to add more language entries as all the translations were on the same file
    so i decided to update it and use a library i found this morning https://github.com/TheWorldMachinima/SSIni
    it has a simpler syntax (.ini) and not the old horrible one (.xml) which can be hell sometimes (no autocompletion!!!)
*/

import openfl.utils.Assets;
import SSIni;
using StringTools;

/* sanco here explaining how this is gonna work
    my old language system was kinda bad since all the entries were accesed with a prefix indicating the state or section of it
    since we using ini now apparently it has sections and might be better 
*/

class Language
{
    private static var curLang(get, null):String;

    // Get the current language, if not found on save return the default one
    @:noCompletion
    private static function get_curLang()
    {
        var saveLang:String = data.KadeEngineData.settings.data.language;
        return (saveLang != null ? saveLang : 'en_US');
    }

    // Holds the ini file content access
    private static var ini:SSIni;

    // This will refresh the ini content - why the fuck was it inlined
    public static function populate(?targetLang:String)
    {
        trace('Current language: $curLang [Target: $targetLang]');

        // yes galo i moved to haxe 4.3^
        final endLang:String = targetLang ?? curLang;

        try
        {
            ini = new SSIni();

            // aint publishin a modified version so we just changing them regex on here
            // its supposed to work on both targets but will only set it for html5
            #if html5
            @:privateAccess
            {
                ini.helper.RegEx.Section = ~/^\[([^\]]*)\]$/;
            }
            #end

            ini.doString(Assets.getText('assets/locale/$endLang.ini'));
        }
        catch (ex)
        {
            trace('Failed to populate INI $ex');
        }
    }

    // easy stuff
    public inline static function get(section:String, id:String):Dynamic
    {
        inline function normalize(v:String):String
            return StringTools.replace(v, "\\n", '\n'); // please make sense PLEASE

        var data:Dynamic = Reflect.field(ini.getSection(section), id);

        if (data is String)
        {
            data = normalize(data);
        }
        else if (data is Array)
        {
            // imm gonna leave it as it is for you galito
            final newData = cast (data, Array<Dynamic>);

            for (i in newData)
            {
                if (i is String)
                {
                    final index = newData.indexOf(i);
                    i = normalize(i);
                    data[index] = i;
                }
            }
        }

        return data;
    }

    public inline static function getSection(section:String):Dynamic
    {
        return ini.getSection(section);
    }
}