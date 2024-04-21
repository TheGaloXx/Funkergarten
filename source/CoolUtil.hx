package;

import flixel.sound.FlxSound;
import lime.app.Application;
import flixel.FlxSprite;
import openfl.filters.GlowFilter;
import Discord.DiscordClient;
import flixel.graphics.frames.FlxFilterFrames;
import data.GlobalData;
import flixel.FlxG;
import flixel.math.FlxMath;
import states.PlayState;
import haxe.DynamicAccess;
import flixel.util.FlxAxes;

using StringTools;

class CoolUtil
{
	public static var volume:Float = 100;

	public static function difficultyFromInt(difficulty:Int):String
	{
		return Language.get('Difficulties', '$difficulty');
	}

	inline public static function boundTo(value:Float, min:Float = 0, max:Float = 1):Float 
	{
		return FlxMath.bound(value, min, max);
	}

	public static function getDialogue(?fromSection:String):Array<String>
	{
		var dialogue:Array<String> = [];

		if (fromSection != null)
		{
			var langDialogue:DynamicAccess<Dynamic> = Language.getSection(fromSection);
			for (idx => val in langDialogue)
			{
				dialogue[Std.parseInt(idx)] = val;
			}

			return dialogue;
		}

		var song = PlayState.SONG.song;

		var suffix:String = '';
		if ((!GlobalData.settings.mechanicsEnabled || PlayState.storyDifficulty == 0) && Reflect.fields(Language.getSection('${song}_Dialogue_ALT')).length > 0)
			suffix = '_ALT';

		// omg im so fucking smart
		var langDialogue:DynamicAccess<Dynamic> = Language.getSection('${song}_Dialogue' + suffix);
		for (idx => val in langDialogue)
		{
			dialogue[Std.parseInt(idx)] = val;
		}

		return dialogue;
	}

	private static var scroll_snd:FlxSound;

	static public function sound(sound:String, library:String = '', volume:Float = 1)
	{
		if (sound == 'scrollMenu')
		{
			if (!scroll_snd?.exists)
			{
				scroll_snd = new FlxSound();
				scroll_snd.loadEmbedded(Paths.sound(sound, library));
			}

			FlxG.sound.list.add(scroll_snd);

			scroll_snd.stop();
			scroll_snd.volume = volume;
			scroll_snd.play();

			return;
		}

		FlxG.sound.play(Paths.sound(sound, library), volume);
	}

	/**
	 * Function that changes the `Discord Rich Presence`.
	 * @param   state   The second line in the presence (use it for misses).
	 * @param   details   The first line in the presence (use for current state and song details).
	 * @param   hasStartTimestamp      Time left indicator (ignore).
	 * @param   endTimestamp     End time indicator (ignore).
	 * @param   smallImageKey The small image name.
    **/

	public static function presence(state:String, details:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float, smallImageKey:String, addLittleIcon:Bool = false)
	{
		DiscordClient.changePresence(state, details, hasStartTimestamp, endTimestamp, smallImageKey, addLittleIcon);
	}

    public static function firstLetterUpperCase(string:String):String 
	{
		// way shorter 😍 - yeah galo from the past you fucking love one-liners you stupid fuck 😍
		return (string.charAt(0).toUpperCase() + string.substring(1, string.length)).replace('-', ' ');
	}

	public static function title(state:String, deleteAppTitle:Bool = false)
	{
		var daTitle:String = "";
		if (!deleteAppTitle)
			daTitle = 'Funkergarten' /* Main.appTitle */;

		if (state != null && state != "")
			daTitle = ('$daTitle - $state');

		Application.current.window.title = daTitle;
	}

	public static function glow(sprite:FlxSprite, blurX:Int = 50, blurY = 50, color:Int = 0x000000):Void
	{
		// long ass code for glow effect. Got it from https://haxeflixel.com/demos/FlxSpriteFilters
		FlxFilterFrames.fromFrames(sprite.frames, blurX, blurY, [new GlowFilter(color, sprite.alpha, blurX, blurY, 3)]).applyToSprite(sprite, false, true);
	}

	public static function middleSprite(staticSprite:FlxSprite, toMoveSprite:FlxSprite, axes:FlxAxes):Void
	{
		var x = (staticSprite.x + (staticSprite.width / 2)) - (toMoveSprite.width / 2);
		var y = (staticSprite.y + (staticSprite.height / 2)) - (toMoveSprite.height / 2);

		if      (axes == X)		toMoveSprite.x = x;
		else if (axes == Y)		toMoveSprite.y = y;
		else if (axes == XY)	toMoveSprite.setPosition(x, y);
	}

	public static function size(sprite:FlxSprite, mult:Float, updateHitbox:Bool = true, height:Bool = false):Void
	{
		if (!height)
			sprite.setGraphicSize(Std.int(sprite.width * mult));
		else
			sprite.setGraphicSize(0, Std.int(sprite.height * mult));

		if (updateHitbox)
			sprite.updateHitbox();
	}

	public static function truncateFloat(number:Float, precision:Int):Float 
	{
		var num = number * Math.pow(10, precision);
		return Math.round(num) / Math.pow(10, precision);
	}

	public static function overlaps(spr:flixel.FlxSprite):Bool
	{
		// I spent hours trying to make this work, but thanks to ✦ Sword ✦ (swordcube) from the official Haxe Discord server it works now!!!
		return spr.overlapsPoint(FlxG.mouse.getWorldPosition(spr.camera), true, spr.camera);
	}

	public inline static function normalize(path:String):String
	{
		return StringTools.replace(path, " ", "-").toLowerCase();
	}

	public static inline function convertVolume(oldValue:Float):Float
	{
		oldValue = FlxMath.bound(oldValue, 0, 100);

		// i wanted to implement this: https://www.reddit.com/r/programming/comments/9n2y0/stop_making_linear_volume_controls
		// "slider widget returns a value between 0 and 100, divide that by 100, then square it"
		var newVolume:Float = Math.pow(oldValue / 100, 2);

		return newVolume;
	}

	public static function changeVolume(value:Float, equalTo:Bool = false):Void
	{
		FlxG.sound.muted = false;

		if (equalTo)
			CoolUtil.volume = value;
		else
			CoolUtil.volume += value;

		CoolUtil.volume = FlxMath.bound(CoolUtil.volume, 0, 100);

		FlxG.sound.volume = CoolUtil.convertVolume(CoolUtil.volume);
		Main.tray.show();
	}

	public static function uncachCharacters():Void
	{
		var characters:Int = 0;
		var names:Array<String> = [];

		@:privateAccess
		for (key => i in FlxG.bitmap._cache)
		{
			// trace(key, key.contains('characters'));

			if (!key.contains('characters'))
				continue;

			final graphic = FlxG.bitmap.get(key);

			if (graphic != null)
			{
				if (graphic.persist)
					continue;

				characters++;

				var path:Array<String> = key.split('/');
				names.push(path.pop());

				FlxG.bitmap.remove(graphic);
			}
		}

		if (characters > 0)
			trace('Cleaned $characters character sprites from the cache. ($names)');
	}
}


