package funkin;

import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef EpicEvent =
{
    var strumTime:Null<Float>;
    var name:String;
    var value:String;
    var value2:String;
}

class SongEvents
{
	public static function loadJson(song:String):Array<Dynamic>
	{
        var eventList:Array<Dynamic> = [];
        var path = Paths.json('$song/events', (states.PlayState.SONG.song == 'Nugget de Polla' ? 'shit' : 'preload'));

        trace('Events JSON exists: ' + Assets.exists(path) + '.');

        if (!Assets.exists(path)) return null;

		var jsonInfo = Assets.getText(path).trim();
		while (!jsonInfo.endsWith("}")) jsonInfo = jsonInfo.substr(0, jsonInfo.length - 1);

        var shit = cast Json.parse(jsonInfo);        
        if (shit == null || shit.song == null || shit.song.events == null) return [];

        eventList = shit.song.events;
        if (eventList.length > 0) eventList.sort(sortByTime);

        return eventList;
	}

    private static function sortByTime(Obj1:EpicEvent, Obj2:EpicEvent)
    {
        return flixel.util.FlxSort.byValues(flixel.util.FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
    }

    public inline static function makeEvent(name:String, ?value1:Dynamic, ?value2:Dynamic):EpicEvent
    {
        return {
            strumTime: 0,
            name: name,
            value: value1,
            value2: value2
        }
    }
}
