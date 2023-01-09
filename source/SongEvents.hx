/*class SongEvents
{
    function elPepe(){}
    function eteSech(){}
} //I might actually make this later - I love you Galo
  good ending: i made this later :)     
  nvm im useless, sanco's gonna make it */

package;

import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef EpicEvents = //json shit
{
	var zoom:Float;
	var cameraBop:Float;
    var speedChange:Float;
}

class Events
{
	public var zoom:Float;
	public var cameraBop:Float;
    public var speedChange:Float;

    public static function parseJSON(json:String):EpicEvents
        {
            //analiza el json
            var events:EpicEvents = cast Json.parse(json);
            return events;
        }

	public static function loadJson(jsonFile:String, ?folder:String):EpicEvents
	{
        //busca el .json en la carpeta de la cancion
		var jsonInfo = Assets.getText(Paths.json(folder + '/' + jsonFile.toLowerCase())).trim();

		while (!jsonInfo.endsWith("}")) //remueve todos los caracteres finales hasta que el archivo termine con "}" para evitar errores
		{
			jsonInfo = jsonInfo.substr(0, jsonInfo.length - 1);
		}

		return parseJSON(jsonInfo);
	}
}
