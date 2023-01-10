package;

import flixel.util.FlxSort;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef EpicEvent =
{
    var step:Int;
    var beat:Int;
    var name:String;
    var value:Float;

    // estas dos vaiables habian sido hechas por si acaso poner dos mismos eventos en el mismo beat no iba a funcionar pero al final si funciono
    //var name2:String;
    //var value2:Float;
}

class SongEvents
{
    public static var eventList:Array<EpicEvent> = [];

	public static function loadJson(jsonFile:String, ?folder:String)
	{
        eventList = [];

        //busca el .json en la carpeta de la cancion
        var path = Paths.json(folder + '/' + jsonFile.toLowerCase());
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
        var val1:Int = (Obj1.step != null ? Obj1.step : Obj1.beat); // si el step no es null, se usan los steps, si no se usan los beats
        var val2:Int = (Obj2.step != null ? Obj2.step : Obj2.beat);
        return FlxSort.byValues(FlxSort.ASCENDING, val1, val2);
    }
}
