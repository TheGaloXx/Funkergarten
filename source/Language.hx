package;

// galo puedes quitar los comentarios que pienses que son inutiles o los que hayas leido

/* sanco here, 
    i thought on doing it my way (https://github.com/SanicBTW/Just-Another-FNF-Engine/blob/221672cfcc8e77ab1db4b5a11e23b14e642425a2/source/base/system/Language.hx)
    but i thought it was going to be hard to add more language entries as all the translations were on the same file
    so i decided to update it and use a library i found this morning https://github.com/TheWorldMachinima/SSIni
    it has a simpler syntax (.ini) and not the old horrible one (.xml) which can be hell sometimes (no autocompletion!!!)
*/
import openfl.utils.Assets;
import SSIni;

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
        var saveLang:String = KadeEngineData.settings.data.language;
        return (saveLang != null ? saveLang : 'en_US');
    }

    // Holds the ini file content access
    private static var ini:SSIni;

    // This will refresh the ini content
    public static function populate()
    {
        try
        {
            ini = new SSIni(Assets.getText(Paths.getPath('locale/$curLang.ini', TEXT, 'preload')));
        }
        catch (ex)
        {
            trace('Failed to populate INI $ex');
        }
    }

    // easy stuff
    public static function get(section:String, id:String):Dynamic
    {
        return Reflect.field(ini.getSection(section), id);
    }

    public static function getSection(section:String):Dynamic
    {
        return ini.getSection(section);
    }
}