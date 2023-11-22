package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	private inline static final SOUND_EXT = "ogg";
	
	// why the fuck is this private galo
	public inline static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		var levelPath = getLibraryPathForce(file, "shared");
		if (OpenFlAssets.exists(levelPath, type))
			return levelPath;

		return getPreloadPath(file);
	}

	private static inline function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	private inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	private inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static private function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static private function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static private function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('$key.json', TEXT, library);
	}

	inline static public function sound(key:String, ?library:String)
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
		var songLowercase = CoolUtil.normalize(song);

		if (songLowercase != 'nugget-de-polla')
			return 'songs:assets/songs/$songLowercase/Voices.$SOUND_EXT';
		else
			return 'shit:assets/shit/songs/$songLowercase/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		var songLowercase = CoolUtil.normalize(song);

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

	static inline public function loadJSON(key:String, ?library:String):Dynamic
	{
		try
		{
			return haxe.Json.parse(OpenFlAssets.getText(json(key, library)));
		}
		catch (e)
		{
			trace("AN ERROR OCCURRED parsing a JSON file.");
			trace(e.message);

			return null;
		}
	}

	inline static public function pixel() return getSparrowAtlas('gameplay/pixel/pixel_assets', 'shared');
	inline static public function ui() return getSparrowAtlas('gameplay/UI', 'shared');
}