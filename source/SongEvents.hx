package;

import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef EpicEvent =
{
    var step:Null<Int>;
    var name:String;
    var value:String;
    var value2:String;
}

class SongEvents
{
    public static var eventList:Array<EpicEvent> = [];

	public static function loadJson(jsonFile:String, ?folder:String)
	{
        eventList = [];

        //busca el .json en la carpeta de la cancion
        var path = Paths.json(folder + '/' + jsonFile.toLowerCase(), (PlayState.SONG.song == 'Nugget de Polla' ? 'shit' : 'preload'));
        trace('Events JSON exists: ' + Assets.exists(path) + '.');
        if (!Assets.exists(path))
            return; // si el archivo no existe parar el script, crashea si no lo encuentra asi que esto es necesario Bv
		var jsonInfo = Assets.getText(path).trim();

		while (!jsonInfo.endsWith("}")) //remueve todos los caracteres finales hasta que el archivo termine con "}" para evitar errores
		{
			jsonInfo = jsonInfo.substr(0, jsonInfo.length - 1);
		}

        // automaticamente añade los eventos a la lista
        eventList = cast Json.parse(jsonInfo).events;
        if (eventList.length > 0) // por si acaso xd
            eventList.sort(sortByTime);
	}

    private static function sortByTime(Obj1:EpicEvent, Obj2:EpicEvent)
    {
        return flixel.util.FlxSort.byValues(flixel.util.FlxSort.ASCENDING, Obj1.step, Obj2.step);
    }
}
