package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	//a //b
	
	inline public static var SOUND_EXT = "ogg";

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	// why the fuck is this private galo
	public static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
			switch (songLowercase) {
				case 'dad-battle': songLowercase = 'dadbattle';
				case 'philly-nice': songLowercase = 'philly';
			}

		if (songLowercase != 'nugget-de-polla')
			return 'songs:assets/songs/$songLowercase/Voices.$SOUND_EXT';
		else
			return 'shit:assets/shit/songs/$songLowercase/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
			switch (songLowercase) {
				case 'dad-battle': songLowercase = 'dadbattle';
				case 'philly-nice': songLowercase = 'philly';
			}

		if (songLowercase != 'nugget-de-polla')
			return 'songs:assets/songs/${songLowercase}/Inst.$SOUND_EXT';
		else
			return 'shit:assets/shit/songs/$songLowercase/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function video(key:String)
	{
		return 'assets/videos/$key.mp4';
	}

	static public function loadJSON(key:String, ?library:String):Dynamic
	{
		try
		{
			return haxe.Json.parse(OpenFlAssets.getText(Paths.json(key, library)));
		}
		catch (e)
		{
			trace("AN ERROR OCCURRED parsing a JSON file.");
			trace(e.message);

			return null;
		}
	}
}

/*
package;

class Paths
{	
	inline public static var SOUND_EXT = "ogg";

	inline static public function file(file:String, ?library:String)
	{
		if (library == 'preload')
			return 'assets/$file';
		else
			return 'assets/$library/$file';
	}

	inline static public function xml(key:String, ?library:String)
	{
		if (library == 'preload')
			return 'assets/images/$key.xml';
		else
			return 'assets/$library/images/$key.xml';
	}

	inline static public function json(key:String, ?library:String)
	{
		if (library == 'preload')
			return 'assets/data/$key.json';
		else
			return 'assets/$library/data/$key.json';
	}

	static public function sound(key:String, ?library:String)
	{
		if (library == 'preload')
			return 'assets/sounds/$key.$SOUND_EXT';
		else
			return 'assets/$library/sounds/$key.$SOUND_EXT';
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + flixel.FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		if (library == 'preload')
			return 'assets/music/$key.$SOUND_EXT';
		else
			return 'assets/$library/music/$key.$SOUND_EXT';
	}

	inline static public function voices(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();

		return 'assets/songs/${songLowercase}/Voices.$SOUND_EXT';
	}

	inline static public function EmbedVoices(song:String)
		{
			var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
	
			return 'assets/shit/songs/${songLowercase}/Voices.$SOUND_EXT';
		}

	inline static public function inst(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();

		return 'assets/songs/${songLowercase}/Inst.$SOUND_EXT';
	}

	inline static public function EmbedInst(song:String)
		{
			var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
	
			return 'assets/shit/songs/${songLowercase}/Inst.$SOUND_EXT';
		}

	inline static public function image(key:String, ?library:String)
	{
		//trace('Image: $key, library: $library, exists: ${openfl.utils.Assets.exists('assets/images/$key.png')}');

		if (library == 'preload')
			return 'assets/images/$key.png';
		else
			return 'assets/$library/images/$key.png';
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return flixel.graphics.frames.FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function video(key:String)
	{
		return 'assets/videos/$key.mp4';
	}

	static public function loadJSON(key:String, ?library:String):Dynamic
		{
			try
			{
				return haxe.Json.parse(openfl.utils.Assets.getText(json(key, library)));
			}
			catch (e)
			{
				trace("AN ERROR OCCURRED parsing a JSON file.");
				trace(e.message);
	
				return null;
			}
		}
	}
*/	