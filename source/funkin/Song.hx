package funkin;

import funkin.Section.SwagSection;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var notes:Array<SwagSection>;
	var bpm:Float;
	var speed:Float;

	var name:String;
	var shaders:Array<String>;
	var author:Array<String>;
	var enemy:String;
	var player:String;
	var stage:String;
	var isPixel:Bool;
}

class Song
{
	public static function loadFromJson(jsonInput:String, ?folder:String, isPolla:Bool = false):SwagSong
	{
		var folderLowercase = CoolUtil.normalize(folder);
		
		trace('loading ' + folderLowercase + '/' + jsonInput.toLowerCase());

		var rawJson:String = '';

		if (isPolla)
			rawJson = Assets.getText(Paths.json('songs/' + folderLowercase + '/' + jsonInput.toLowerCase(), 'shit')).trim();
		else
			rawJson = Assets.getText(Paths.json(folderLowercase + '/' + jsonInput.toLowerCase(), 'songs')).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONshit(rawJson, folderLowercase);
	}

	public static function parseJSONshit(rawJson:String, ?rawSongName:String):SwagSong
	{
		var chart:SwagSong = cast Json.parse(rawJson).song;
		var songData:Dynamic = Json.parse(Assets.getText(Paths.json('songs-data/$rawSongName', 'shit')).trim());

		for (field in Reflect.fields(songData))
		{
			Reflect.setField(chart, field, Reflect.field(songData, field));
		}

		return chart;
	}
}