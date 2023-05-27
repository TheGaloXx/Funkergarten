package;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard", "Survivor"];

	public static function difficultyFromInt(difficulty:Int):String
	{
		return Language.get('Difficulties', '$difficulty');
	}

	//Psych Engine
	inline public static function boundTo(value:Float, min:Float, max:Float):Float 
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function getDialogue(?fromSection:String):Array<String>
	{
		var dialogue:Array<String> = ['dad:a:false:false', 'bf:a:true:true'];

		if (fromSection != null)
		{
			var langDialogue:haxe.DynamicAccess<Dynamic> = Language.getSection(fromSection);
			for (idx => val in langDialogue)
			{
				dialogue[Std.parseInt(idx)] = val;
			}
			return dialogue;
		}

		var song = PlayState.SONG.song;

		// omg im so fucking smart
		var langDialogue:haxe.DynamicAccess<Dynamic> = Language.getSection('${song}_Dialogue');
		for (idx => val in langDialogue)
		{
			dialogue[Std.parseInt(idx)] = val;
		}

		return dialogue;
	}

	inline static public function sound(sound:String, library:String = '', volume:Float = 1)
	{
		flixel.FlxG.sound.play(Paths.sound(sound, library), volume * KadeEngineData.settings.data.soundVolume); //in case i want to remove the new sound system i can just delete the " * KadeEngineData.settings.data.soundVolume"	// i just noticed that i could just set the KadeEngineData.settings.data.soundVolume to 1 and it was the same... anyways its done so fuck it
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
		Discord.DiscordClient.changePresence(state, details, hasStartTimestamp, endTimestamp, smallImageKey, addLittleIcon);
	}

    public static function firstLetterUpperCase(string:String):String 
        {
			//way shorter 😍
            return (string.charAt(0).toUpperCase() + string.substring(1, string.length)).replace('-', ' ');
        }

	public static function title(state:String, deleteAppTitle:Bool = false)
	{
		var daTitle:String = "";
		if (!deleteAppTitle)
			daTitle = Main.appTitle;

		if (state == null || state == "")
			lime.app.Application.current.window.title = daTitle;
		else
			lime.app.Application.current.window.title = ('$daTitle - $state');
	}

	public static function glow(sprite:flixel.FlxSprite, blurX:Int = 50, blurY = 50, color:Int = 0x000000):Void
	{
		//long ass code for glow effect. Got it from https://haxeflixel.com/demos/FlxSpriteFilters
		flixel.graphics.frames.FlxFilterFrames.fromFrames(sprite.frames, blurX, blurY, [new openfl.filters.GlowFilter(color, sprite.alpha, blurX, blurY, 3)]).applyToSprite(sprite, false, true);
	}

	public static function middleSprite(staticSprite:flixel.FlxSprite, toMoveSprite:flixel.FlxSprite, axes:flixel.util.FlxAxes):Void
	{
		var x = (staticSprite.x + (staticSprite.width / 2)) - (toMoveSprite.width / 2);
		var y = (staticSprite.y + (staticSprite.height / 2)) - (toMoveSprite.height / 2);

		if      (axes == X)		toMoveSprite.x = x;
		else if (axes == Y)		toMoveSprite.y = y;
		else if (axes == XY)	toMoveSprite.setPosition(x, y);
	}

	public static function size(sprite:flixel.FlxSprite, mult:Float, updateHitbox:Bool = true, height:Bool = false):Void
	{
		if (!height)
			sprite.setGraphicSize(Std.int(sprite.width * mult));
		else
			sprite.setGraphicSize(0, Std.int(sprite.height * mult));

		if (updateHitbox)
			sprite.updateHitbox();
	}
}


