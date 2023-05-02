package;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard", "Survivor"];

	public static function difficultyFromInt(difficulty:Int):String
	{
		if (KadeEngineData.settings.data.esp)
			difficultyArray = ['Facil', "Normal", "Dificil", "Superviviente"];
		else
			difficultyArray = ['Easy', "Normal", "Hard", "Survivor"];
	
		return difficultyArray[difficulty];
	}

	//Psych Engine
	inline public static function boundTo(value:Float, min:Float, max:Float):Float 
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function getDialogue():Array<String>
		{
			var dialogue:Array<String> = ['dad:a:false:false', 'bf:a:true:true'];
			var song = PlayState.SONG.song;

			if (KadeEngineData.settings.data.esp)
			{
				switch (song)
				{
					// 	character:dialogue:angry:yellow
	// example: nugget:hi im nugget:*scream*:highlighted text
					case 'DadBattle':
						dialogue = ['dad: test test', 'bf: wait, this shouldnt work because there is no dad icon', 'dad: shut the fuck up'];
					case 'Nugget':
						dialogue = ["bf:¡Beep!", "nugget:Hola, bienvenido a la Cueva Nugget.", 'nugget:A Nugget nadie lo ama ni tampoco tiene amigos.', 'bf:¿Beep?', 'nugget:¿Curioso acerca de las formas de Nugget?', 'bf:Bop.', 'nugget:¿Una batalla de rap?:false:true', 'nugget:Interesante...'];
					case 'Pills':
						dialogue = ["bf:Beep.", 'nugget:Nugget ha hecho lo que le pediste, ahora deja a Nugget en paz.', 'bf:Skdoo bep.', 'nugget:Estás estresando al pobre Nugget, Nugget necesita tomar sus pastillas .', 'nugget:*Gulp* Mucho mejor. ¿De qué estábamos hablando?', 'bf:Beep?', "nugget:¿Rap? Solo una canción y te vas."];

						//dialogue = ["nugget:Now get out, I'm busy."];
					default:
						trace('uh oh');
				}
			}
			else
			{
				switch (song)
				{
					// 	character:dialogue:angry:yellow
	// example: nugget:hi im nugget:*scream*:highlighted text
					case 'DadBattle':
						dialogue = ['protagonist:Normal text', 'protagonist:Angry text:true', 'protagonist:Hint text::true', 'protagonist:Angry hint text:true:true'];
					case 'Monday':
						dialogue = ['protagonist:I banged your mom.', 'bf: beep'];
					case 'Nugget':
						dialogue = ["bf:Beep!", "nugget:Hi, welcome to the Nugget Cave.", 'nugget:Nugget knows no love or friendship.', 'bf:Beep?', 'nugget:You are curious about the ways of Nugget?', 'bf:Bop.', 'nugget:A rap battle?:false:true', 'nugget:Interesting...'];
					default:
						trace('uh oh');
				}
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
			sprite.setGraphicSize(Std.int(sprite.height * mult));

		if (updateHitbox)
			sprite.updateHitbox();
	}
}


